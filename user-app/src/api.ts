import { Platform } from 'react-native';
import * as SecureStore from 'expo-secure-store';

const configuredUrl = process.env.EXPO_PUBLIC_API_URL?.trim();
const devUrl = Platform.OS === 'android' ? 'http://10.0.2.2:3000/api' : 'http://localhost:3000/api';
const apiBase = configuredUrl || (__DEV__ ? devUrl : '');

async function read(key: string) {
  if (Platform.OS === 'web') {
    return typeof localStorage === 'undefined' ? null : localStorage.getItem(`helpi.${key}`);
  }
  return SecureStore.getItemAsync(`helpi.${key}`);
}

async function write(key: string, value: string | null) {
  if (Platform.OS === 'web') {
    if (typeof localStorage === 'undefined') return;
    if (value === null) localStorage.removeItem(`helpi.${key}`);
    else localStorage.setItem(`helpi.${key}`, value);
    return;
  }
  if (value === null) await SecureStore.deleteItemAsync(`helpi.${key}`);
  else await SecureStore.setItemAsync(`helpi.${key}`, value);
}

let accessToken: string | null = null;
let refreshPromise: Promise<boolean> | null = null;

export const session = {
  async restore() {
    accessToken = await read('access');
    return accessToken;
  },
  async save(access: string, refresh: string) {
    accessToken = access;
    await Promise.all([write('access', access), write('refresh', refresh)]);
  },
  async clear() {
    accessToken = null;
    await Promise.all([write('access', null), write('refresh', null)]);
  },
};

export class ApiError extends Error {
  constructor(message: string, public readonly status?: number) {
    super(message);
    this.name = 'ApiError';
  }
}

async function refreshSession() {
  if (refreshPromise) return refreshPromise;
  refreshPromise = (async () => {
    const refreshToken = await read('refresh');
    if (!refreshToken) return false;
    try {
      const result = await request<{ accessToken: string; refreshToken: string }>(
        'POST', '/auth/refresh', { refreshToken }, false,
      );
      await session.save(result.accessToken, result.refreshToken);
      return true;
    } catch {
      await session.clear();
      return false;
    }
  })().finally(() => { refreshPromise = null; });
  return refreshPromise;
}

async function request<T>(method: string, path: string, body?: unknown, retry = true): Promise<T> {
  if (!apiBase) throw new ApiError('Helpi’s backend address has not been configured for this app yet.');
  let response: Response;
  try {
    response = await fetch(`${apiBase}${path}`, {
      method,
      headers: {
        'Content-Type': 'application/json',
        'X-Timestamp': String(Date.now()),
        'X-Client-Platform': Platform.OS === 'web' ? 'expo-web' : 'expo-android',
        ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
      },
      ...(body === undefined ? {} : { body: JSON.stringify(body) }),
    });
  } catch {
    throw new ApiError('Could not connect to Helpi. Check your connection and try again.');
  }

  if (response.status === 401 && retry && accessToken && !path.startsWith('/auth/')) {
    if (await refreshSession()) return request<T>(method, path, body, false);
  }

  let data: unknown;
  try { data = await response.json(); } catch { data = {}; }
  if (!response.ok) {
    const message = (data as { message?: string | string[] })?.message;
    throw new ApiError(Array.isArray(message) ? message.join(', ') : message || `Request failed (${response.status}).`, response.status);
  }
  return data as T;
}

export type HelpCase = {
  id: string;
  title?: string;
  category: string;
  goalMinor: number;
  currency: string;
  countryCode: string;
  city?: string;
  publicDisplayName?: string;
  publicIdentityMode?: string;
  createdAt?: string;
  status?: string;
};

export const api = {
  get baseUrl() { return apiBase; },
  login: (email: string, password: string, mfaCode?: string) =>
    request<{ accessToken: string; refreshToken: string; user: Record<string, unknown> }>(
      'POST', '/auth/login', { email, password, ...(mfaCode ? { mfaCode } : {}) }, false,
    ),
  register: (data: Record<string, unknown>) =>
    request<{ verificationRequired?: boolean; verificationTokenForDevelopment?: string; accessToken?: string; refreshToken?: string; user?: Record<string, unknown> }>('POST', '/auth/register', data, false),
  verifyEmail: (token: string) => request('POST', '/auth/verify-email', { token }, false),
  me: () => request<Record<string, unknown>>('GET', '/auth/me'),
  logout: async () => {
    const refreshToken = await read('refresh');
    if (refreshToken) await request('POST', '/auth/logout', { refreshToken }, false).catch(() => undefined);
    await session.clear();
  },
  cases: (q = '') => request<HelpCase[]>('GET', `/cases${q ? `?q=${encodeURIComponent(q)}` : ''}`),
  mine: () => request<HelpCase[]>('GET', '/cases/mine'),
  createCase: (data: Record<string, unknown>) => request<HelpCase>('POST', '/cases', data),
  threads: () => request<any[]>('GET', '/messages/threads'),
  threadMessages: (id: string) => request<any[]>('GET', `/messages/threads/${encodeURIComponent(id)}`),
  sendMessage: (id: string, body: string) => request('POST', `/messages/threads/${encodeURIComponent(id)}`, { body }),
  startCaseChat: (caseId: string, offerAmountMinor: number) =>
    request<{ id: string; title?: string }>('POST', '/messages/threads', { caseId, offerAmountMinor }),
  notifications: () => request<any[]>('GET', '/notifications'),
  report: (type: string, description: string) => request('POST', '/reports', { type, description }),
  profile: () => request<Record<string, unknown>>('GET', '/users/profile'),
};
