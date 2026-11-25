export const api = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';

export function saveAdminSession(accessToken: string, refreshToken: string) {
  sessionStorage.setItem('helpi_admin_token', accessToken);
  sessionStorage.setItem('helpi_admin_refresh_token', refreshToken);
}

export function clearAdminSession() {
  sessionStorage.removeItem('helpi_admin_token');
  sessionStorage.removeItem('helpi_admin_refresh_token');
}

export async function adminFetch(path: string, init: RequestInit = {}, fallbackToken = '') {
  const send = (accessToken: string) => fetch(`${api}${path}`, {
    ...init,
    headers: {
      ...Object.fromEntries(new Headers(init.headers).entries()),
      ...(accessToken ? { Authorization: `Bearer ${accessToken}` } : {}),
    },
  });

  const currentToken = sessionStorage.getItem('helpi_admin_token') || fallbackToken;
  const response = await send(currentToken);
  if (response.status !== 401) return response;

  const refreshToken = sessionStorage.getItem('helpi_admin_refresh_token');
  if (!refreshToken || path === '/auth/refresh') return response;

  try {
    const refreshed = await fetch(`${api}/auth/refresh`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ refreshToken }),
    });
    if (!refreshed.ok) throw new Error('Session expired');
    const session = await refreshed.json();
    saveAdminSession(session.accessToken, session.refreshToken);
    return await send(session.accessToken);
  } catch {
    clearAdminSession();
    window.dispatchEvent(new Event('helpi-admin-session-expired'));
    return response;
  }
}
