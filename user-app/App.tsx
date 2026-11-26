import { StatusBar } from 'expo-status-bar';
import React, { useCallback, useEffect, useMemo, useState } from 'react';
import {
  ActivityIndicator, Image, KeyboardAvoidingView, Linking, Platform, Pressable,
  ScrollView, StyleSheet,
  Text, TextInput, View, useWindowDimensions,
} from 'react-native';
import { api, HelpCase, session } from './src/api';

const orange = '#ff7900';
const navy = '#10213d';
const ink = '#17243a';
const muted = '#687386';
const canvas = '#fffaf5';
const border = '#efe4da';
const categories = [
  ['MEDICAL', 'Medical'], ['FOOD', 'Food'], ['EDUCATION', 'Education'], ['HOUSING', 'Housing'],
  ['WATER', 'Clean water'], ['DISABILITY', 'Disability support'], ['EMERGENCY', 'Emergency'],
  ['COMMUNITY', 'Community project'], ['FAMILY', 'Family support'], ['FARMING', 'Farming'],
  ['ELDERLY', 'Older adult'], ['OTHER', 'Other'], ['HARDSHIP', 'Hardship'], ['JOBLESS', 'Unemployment'],
  ['WIDOW', 'Widow'], ['ORPHAN', 'Orphan'], ['WAR_VICTIM', 'War survivor'], ['WAR_SURVIVOR', 'War survivor'],
  ['DISPLACED_PERSON', 'Refugee or displaced person'], ['SINGLE_PARENT', 'Single parent'],
  ['UNEMPLOYED', 'Unemployed person'], ['LOW_INCOME_FAMILY', 'Low-income family'],
  ['CAREGIVER', 'Caregiver'], ['CHRONIC_ILLNESS', 'Chronic illness'], ['HOMELESS', 'Unstable housing'],
  ['TRAFFICKING_SURVIVOR', 'Survivor of trafficking or abuse'],
] as const;
type Tab = 'home' | 'explore' | 'messages' | 'profile';
type Page = Tab | 'create' | 'mine' | 'notifications' | 'case' | 'thread' | 'safety';
type User = Record<string, any>;
type Thread = Record<string, any>;

function categoryLabel(category?: string) {
  return categories.find(([key]) => key === category)?.[1] || category?.replaceAll('_', ' ').toLowerCase().replace(/\b\w/g, (m) => m.toUpperCase()) || 'Community request';
}
function money(amount?: number, currency = 'KES') {
  return `${currency} ${((amount || 0) / 100).toLocaleString(undefined, { maximumFractionDigits: 0 })}`;
}
function initials(name?: string) { return (name || 'H').trim().split(/\s+/).slice(0, 2).map((p) => p[0]?.toUpperCase()).join('') || 'H'; }

function Action({ title, onPress, secondary = false, disabled = false }: { title: string; onPress: () => void; secondary?: boolean; disabled?: boolean }) {
  return <Pressable accessibilityRole="button" disabled={disabled} onPress={onPress} style={({ pressed }) => [styles.action, secondary && styles.actionSecondary, disabled && styles.disabled, pressed && !disabled && styles.pressed]}><Text style={[styles.actionText, secondary && styles.actionSecondaryText]}>{title}</Text></Pressable>;
}

function Field({ label, value, onChangeText, placeholder, secureTextEntry, keyboardType, multiline, autoCapitalize = 'sentences' }: any) {
  return <View style={styles.field}><Text style={styles.fieldLabel}>{label}</Text><TextInput accessibilityLabel={label} value={value} onChangeText={onChangeText} placeholder={placeholder} placeholderTextColor="#9aa2af" secureTextEntry={secureTextEntry} keyboardType={keyboardType} multiline={multiline} autoCapitalize={autoCapitalize} style={[styles.input, multiline && styles.multiline]} /></View>;
}

function CaseCard({ item, onPress, onOffer }: { item: HelpCase; onPress: () => void; onOffer?: () => void }) {
  const label = item.publicDisplayName || (item.publicIdentityMode === 'ANONYMOUS' ? 'Community member' : 'Verified community member');
  return <Pressable onPress={onPress} style={({ pressed }) => [styles.caseCard, pressed && styles.pressed]}>
    <View style={styles.caseTop}><View style={styles.caseIcon}><Text style={styles.caseIconText}>{categoryLabel(item.category).slice(0, 1)}</Text></View><View style={styles.caseHeadline}><Text style={styles.caseCategory}>{categoryLabel(item.category)}</Text><Text style={styles.caseTitle} numberOfLines={2}>{item.title || `${categoryLabel(item.category)} support request`}</Text></View><Text style={styles.chevron}>›</Text></View>
    <Text style={styles.caseMeta}>{label}{item.city ? ` · ${item.city}` : ''}{item.countryCode ? ` · ${item.countryCode}` : ''}</Text>
    <View style={styles.caseBottom}><View><Text style={styles.amount}>{money(item.goalMinor, item.currency)}</Text><Text style={styles.amountCaption}>requested support</Text></View>{onOffer && <Pressable accessibilityRole="button" onPress={(event) => { event.stopPropagation(); onOffer(); }} style={styles.smallAction}><Text style={styles.smallActionText}>Offer help</Text></Pressable>}</View>
  </Pressable>;
}

function App() {
  const { width } = useWindowDimensions();
  const wide = width >= 960;
  const [ready, setReady] = useState(false);
  const [user, setUser] = useState<User | null>(null);
  const [page, setPage] = useState<Page>('home');
  const [tab, setTab] = useState<Tab>('home');
  const [currentThread, setCurrentThread] = useState<Thread | null>(null);
  const [currentCase, setCurrentCase] = useState<HelpCase | null>(null);
  const [notice, setNotice] = useState('');

  useEffect(() => {
    let active = true;
    (async () => {
      try {
        const saved = await session.restore();
        if (saved) {
          const profile = await api.profile();
          if (active) setUser(profile);
        }
      } catch { await session.clear(); }
      if (active) setReady(true);
    })();
    if (Platform.OS === 'web' && typeof navigator !== 'undefined' && 'serviceWorker' in navigator) {
      navigator.serviceWorker.register('/community/sw.js').catch(() => undefined);
    }
    return () => { active = false; };
  }, []);

  const message = useCallback((text: string) => {
    setNotice(text);
    setTimeout(() => setNotice(''), 4800);
  }, []);
  const goTab = (next: Tab) => { setTab(next); setPage(next); };
  const openThread = (thread: Thread) => { setCurrentThread(thread); setPage('thread'); };
  const openCase = (item: HelpCase) => { setCurrentCase(item); setPage('case'); };
  const signedIn = (nextUser: User) => { setUser(nextUser); goTab('home'); };
  const signOut = async () => { await api.logout(); setUser(null); setPage('home'); message('You are signed out.'); };

  if (!ready) return <View style={styles.loading}><ActivityIndicator size="large" color={orange} /><Text style={styles.loadingText}>Getting Helpi ready…</Text></View>;
  if (!user) return <><StatusBar style="dark" /><AuthScreen onSignedIn={signedIn} /></>;

  const nav: { id: Tab; icon: string; label: string }[] = [
    { id: 'home', icon: '⌂', label: 'Home' }, { id: 'explore', icon: '♡', label: 'Find help' },
    { id: 'messages', icon: '☏', label: 'Messages' }, { id: 'profile', icon: '◉', label: 'Profile' },
  ];
  const back = () => setPage(tab);
  const title = ({ home: 'Home', explore: 'Find help', messages: 'Messages', profile: 'Your profile', create: 'Post a request', mine: 'My requests', notifications: 'Notifications', case: 'Request details', thread: currentThread?.case?.title || 'Conversation', safety: 'Privacy & safety' } as Record<Page, string>)[page];

  return <View style={styles.app}>
    <StatusBar style="dark" />
    <View style={[styles.appFrame, wide && styles.appFrameWide]}>
      {wide && <View style={styles.rail}>
        <View style={styles.brand}><Image source={require('./assets/icon.png')} style={{ width: 35, height: 35, borderRadius: 11 }} /><Text style={styles.brandName}>Helpi</Text></View>
        <Text style={styles.railCaption}>COMMUNITY SUPPORT</Text>
        {nav.map((item) => <NavButton key={item.id} {...item} selected={tab === item.id} onPress={() => goTab(item.id)} horizontal />)}
        <View style={styles.railGrow} />
        <Text style={styles.railFoot}>Together, we can help.</Text>
      </View>}
      <View style={styles.main}>
        <View style={styles.topBar}>
          {!wide && <View style={styles.brand}><Image source={require('./assets/icon.png')} style={{ width: 35, height: 35, borderRadius: 11 }} /><Text style={styles.brandName}>Helpi</Text></View>}
          <Text style={styles.topTitle}>{title}</Text>
          <Pressable accessibilityLabel="View notifications" onPress={() => setPage('notifications')} style={styles.bell}><Text style={styles.bellText}>♧</Text></Pressable>
        </View>
        {notice ? <View accessibilityRole="alert" style={styles.notice}><Text style={styles.noticeText}>{notice}</Text></View> : null}
        <ScrollView style={styles.content} contentContainerStyle={[styles.contentInner, wide && styles.contentInnerWide]} keyboardShouldPersistTaps="handled">
          {page === 'home' && <HomeScreen user={user} onExplore={() => goTab('explore')} onCreate={() => setPage('create')} onOffer={openCase} />}
          {page === 'explore' && <ExploreScreen onOffer={openCase} onOpen={openCase} />}
          {page === 'messages' && <MessagesScreen user={user} onOpen={openThread} />}
          {page === 'profile' && <ProfileScreen user={user} onMine={() => setPage('mine')} onNotifications={() => setPage('notifications')} onSafety={() => setPage('safety')} onSignOut={signOut} />}
          {page === 'create' && <CreateScreen user={user} onCancel={back} onSuccess={(text) => { message(text); setPage('mine'); }} />}
          {page === 'mine' && <MyRequests onCreate={() => setPage('create')} />}
          {page === 'notifications' && <NotificationsScreen onBack={back} />}
          {page === 'safety' && <SafetyScreen />}
          {page === 'case' && currentCase && <CaseDetailScreen item={currentCase} onBack={() => setPage(tab)} onOffer={async (amount) => {
            try { const thread = await api.startCaseChat(currentCase.id, Math.round(amount * 100)); openThread({ id: thread.id, case: currentCase }); }
            catch (error) { message(error instanceof Error ? error.message : 'Could not start a conversation.'); }
          }} />}
          {page === 'thread' && currentThread && <ThreadScreen thread={currentThread} user={user} onBack={back} />}
        </ScrollView>
        {wide && page === 'home' && <View style={styles.desktopAction}><Action title="Post a support request" onPress={() => setPage('create')} /></View>}
        {!wide && <View style={styles.bottomNav}>{nav.map((item) => <NavButton key={item.id} {...item} selected={tab === item.id} onPress={() => goTab(item.id)} />)}</View>}
      </View>
    </View>
  </View>;
}

function NavButton({ icon, label, selected, onPress, horizontal }: { icon: string; label: string; selected: boolean; onPress: () => void; horizontal?: boolean }) {
  return <Pressable accessibilityRole="button" accessibilityState={{ selected }} onPress={onPress} style={[styles.navButton, horizontal && styles.navHorizontal, selected && styles.navSelected]}><Text style={[styles.navIcon, selected && styles.navIconSelected]}>{icon}</Text><Text style={[styles.navLabel, selected && styles.navLabelSelected]}>{label}</Text></Pressable>;
}

function AuthScreen({ onSignedIn }: { onSignedIn: (user: User) => void }) {
  const [registering, setRegistering] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [name, setName] = useState(''); const [email, setEmail] = useState('');
  const [password, setPassword] = useState(''); const [country, setCountry] = useState('KE');
  const [mfa, setMfa] = useState('');
  const [verificationRequired, setVerificationRequired] = useState(false);
  const [verificationToken, setVerificationToken] = useState('');
  const submit = async () => {
    setError(''); setBusy(true);
    try {
      if (verificationRequired) {
        await api.verifyEmail(verificationToken.trim());
        const verified = await api.login(email.trim(), password);
        if (!verified.accessToken || !verified.refreshToken) throw new Error('Your email was verified. Sign in to continue.');
        await session.save(verified.accessToken, verified.refreshToken);
        onSignedIn(verified.user);
        return;
      }
      if (registering) {
        const registered = await api.register({ name: name.trim(), email: email.trim(), password, countryCode: country.trim().toUpperCase() });
        if (registered.verificationRequired) {
          setVerificationRequired(true);
          setVerificationToken(registered.verificationTokenForDevelopment || '');
          setError(registered.verificationTokenForDevelopment ? 'Enter the development verification token to activate this account.' : 'Account created. Check your email for the verification link, then enter its token here.');
          return;
        }
        if (!registered.accessToken || !registered.refreshToken || !registered.user) throw new Error('Account created. Verify your email before signing in.');
        await session.save(registered.accessToken, registered.refreshToken);
        onSignedIn(registered.user);
        return;
      }
      const result = await api.login(email.trim(), password, mfa || undefined);
      await session.save(result.accessToken, result.refreshToken);
      onSignedIn(result.user);
    } catch (e) { setError(e instanceof Error ? e.message : 'Could not sign in. Try again.'); }
    finally { setBusy(false); }
  };
  const { width } = useWindowDimensions();
  return <KeyboardAvoidingView style={styles.authPage} behavior={Platform.OS === 'ios' ? 'padding' : undefined}>
    <ScrollView contentContainerStyle={styles.authScroll} keyboardShouldPersistTaps="handled">
      <View style={[styles.authCard, width > 760 && styles.authCardWide]}>
        <Image source={require('./assets/icon.png')} style={{ width: 54, height: 54, borderRadius: 16, marginBottom: 18 }} />
        <Text style={styles.eyebrow}>COMMUNITY SUPPORT</Text>
        <Text style={styles.authTitle}>{verificationRequired ? 'Verify your email' : registering ? 'Join Helpi' : 'Welcome back'}</Text>
        <Text style={styles.authCopy}>{verificationRequired ? 'Enter the verification token from the email sent to your address.' : registering ? 'Create an account to find support or offer help in your community.' : 'Sign in to find support, offer help, and stay connected.'}</Text>
        {registering && !verificationRequired && <Field label="Full name" value={name} onChangeText={setName} placeholder="Your name" autoCapitalize="words" />}
        <Field label="Email" value={email} onChangeText={setEmail} placeholder="you@example.com" keyboardType="email-address" autoCapitalize="none" />
        <Field label="Password" value={password} onChangeText={setPassword} placeholder={registering ? 'At least 12 characters' : 'Your password'} secureTextEntry />
        {verificationRequired ? <Field label="Email verification token" value={verificationToken} onChangeText={setVerificationToken} placeholder="Paste verification token" autoCapitalize="none" /> : registering ? <Field label="Country code" value={country} onChangeText={setCountry} placeholder="KE" autoCapitalize="characters" /> : <Field label="Authenticator code (if enabled)" value={mfa} onChangeText={setMfa} placeholder="6-digit code" keyboardType="number-pad" />}
        {error ? <Text accessibilityRole="alert" style={styles.error}>{error}</Text> : null}
        <Action title={busy ? 'Please wait…' : verificationRequired ? 'Verify and continue' : registering ? 'Create account' : 'Sign in'} disabled={busy} onPress={submit} />
        {!verificationRequired && <Pressable onPress={() => { setError(''); setRegistering(!registering); }} style={styles.switchAuth}><Text style={styles.switchAuthText}>{registering ? 'Already have an account? Sign in' : 'New to Helpi? Create an account'}</Text></Pressable>}
        <Pressable onPress={() => Linking.openURL(process.env.EXPO_PUBLIC_ADMIN_PORTAL_URL || 'https://helpi-eight.vercel.app').catch(() => setError('Could not open the admin portal.'))} style={styles.switchAuth}><Text style={styles.adminLinkText}>Admin portal sign in</Text></Pressable>
        <Text style={styles.privacyLine}>Your information is protected and used to support your account.</Text>
      </View>
    </ScrollView>
  </KeyboardAvoidingView>;
}

function HomeScreen({ user, onExplore, onCreate, onOffer }: { user: User; onExplore: () => void; onCreate: () => void; onOffer: (item: HelpCase) => void }) {
  const [items, setItems] = useState<HelpCase[]>([]); const [loading, setLoading] = useState(true); const [error, setError] = useState('');
  const load = useCallback(async () => { setError(''); try { setItems(await api.cases()); } catch (e) { setError(e instanceof Error ? e.message : 'Could not load requests.'); } finally { setLoading(false); } }, []);
  useEffect(() => { void load(); }, [load]);
  return <View>
    <View style={styles.welcomeCard}><Text style={styles.welcomeKicker}>A little help goes a long way</Text><Text style={styles.welcomeTitle}>Hello, {user.name?.split(' ')[0] || 'friend'}.</Text><Text style={styles.welcomeBody}>Find a nearby request or share what your community needs.</Text><View style={styles.welcomeActions}><Action title="Find someone to help" onPress={onExplore} /><Action title="Post a request" secondary onPress={onCreate} /></View></View>
    <SectionHeading title="Community requests" action="See all" onPress={onExplore} />
    {error ? <ErrorCard message={error} onRetry={load} /> : loading ? <LoadingCard /> : items.length === 0 ? <EmptyCard title="No requests yet" body="Check back soon or share this app with your community." /> : items.slice(0, 4).map((item) => <CaseCard key={item.id} item={item} onPress={() => onOffer(item)} onOffer={() => onOffer(item)} />)}
    <View style={styles.hintCard}><Text style={styles.hintIcon}>✳</Text><View style={styles.flex}><Text style={styles.hintTitle}>Help safely</Text><Text style={styles.hintCopy}>Keep conversations on Helpi. Never share passwords or payment codes.</Text></View></View>
  </View>;
}

function ExploreScreen({ onOffer, onOpen }: { onOffer: (item: HelpCase) => void; onOpen: (item: HelpCase) => void }) {
  const [query, setQuery] = useState(''); const [items, setItems] = useState<HelpCase[]>([]); const [loading, setLoading] = useState(false); const [error, setError] = useState('');
  const load = useCallback(async (q: string) => { setLoading(true); setError(''); try { setItems(await api.cases(q)); } catch (e) { setError(e instanceof Error ? e.message : 'Could not load requests.'); } finally { setLoading(false); } }, []);
  useEffect(() => { void load(''); }, [load]);
  const filters = useMemo(() => categories.slice(0, 8), []);
  return <View>
    <Text style={styles.screenLead}>Browse requests shared by people in the community.</Text>
    <View style={styles.searchRow}><Text style={styles.searchIcon}>⌕</Text><TextInput value={query} onChangeText={setQuery} onSubmitEditing={() => void load(query.trim())} placeholder="Search requests" returnKeyType="search" style={styles.searchInput} /><Pressable accessibilityLabel="Search requests" onPress={() => void load(query.trim())} style={styles.searchGo}><Text style={styles.searchGoText}>Search</Text></Pressable></View>
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.chipRow}>{filters.map(([key, label]) => <Pressable key={key} onPress={() => { setQuery(label); void load(label); }} style={styles.chip}><Text style={styles.chipText}>{label}</Text></Pressable>)}</ScrollView>
    {error ? <ErrorCard message={error} onRetry={() => load(query)} /> : loading ? <LoadingCard /> : items.length === 0 ? <EmptyCard title="No matching requests" body="Try a different search or check back later." /> : items.map((item) => <CaseCard key={item.id} item={item} onPress={() => onOpen(item)} onOffer={() => onOffer(item)} />)}
  </View>;
}

function CaseDetailScreen({ item, onBack, onOffer }: { item: HelpCase; onBack: () => void; onOffer: (amount: number) => Promise<void> }) {
  const [amount, setAmount] = useState(''); const [busy, setBusy] = useState(false); const [error, setError] = useState('');
  const offer = async () => { const value = Number(amount); if (!Number.isFinite(value) || value <= 0) { setError('Enter the amount you would like to offer.'); return; } setError(''); setBusy(true); try { await onOffer(value); } catch { /* Parent reports API errors to the shared notice. */ } finally { setBusy(false); } };
  return <View><Pressable onPress={onBack} style={styles.backButton}><Text style={styles.backText}>‹  Back to requests</Text></Pressable><View style={styles.caseDetail}><View style={styles.caseIcon}><Text style={styles.caseIconText}>{categoryLabel(item.category).slice(0, 1)}</Text></View><Text style={styles.caseCategory}>{categoryLabel(item.category)}</Text><Text style={styles.detailTitle}>{item.title || `${categoryLabel(item.category)} support request`}</Text><Text style={styles.caseMeta}>{item.publicDisplayName || (item.publicIdentityMode === 'ANONYMOUS' ? 'Community member' : 'Verified community member')}{item.city ? ` · ${item.city}` : ''}{item.countryCode ? ` · ${item.countryCode}` : ''}</Text><View style={styles.detailAmount}><Text style={styles.detailAmountValue}>{money(item.goalMinor, item.currency)}</Text><Text style={styles.amountCaption}>requested support</Text></View><Text style={styles.formIntro}>If you can help, enter the amount you would like to offer. Helpi will start a private conversation with the requester.</Text><Field label={`Your offer (${item.currency || 'KES'})`} value={amount} onChangeText={setAmount} placeholder="Enter amount" keyboardType="decimal-pad" />{error ? <Text accessibilityRole="alert" style={styles.error}>{error}</Text> : null}<Action title={busy ? 'Starting conversation…' : 'Offer help'} disabled={busy} onPress={offer} /><Text style={styles.safetyNote}>Keep personal and payment details private until you have verified the request.</Text></View></View>;
}

function CreateScreen({ user, onCancel, onSuccess }: { user: User; onCancel: () => void; onSuccess: (text: string) => void }) {
  const [category, setCategory] = useState(String(user.supportGroup || ''));
  const [amount, setAmount] = useState(''); const [currency, setCurrency] = useState('KES');
  const [country, setCountry] = useState(String(user.countryCode || 'KE'));
  const [alias, setAlias] = useState(String(user.publicAlias || ''));
  const [anonymous, setAnonymous] = useState(user.publicIdentityMode === 'ANONYMOUS' || user.publicIdentityMode === 'ALIAS');
  const [busy, setBusy] = useState(false); const [error, setError] = useState('');
  const save = async () => {
    const parsed = Number(amount);
    if (!category) { setError('Choose the community group that best describes this request.'); return; }
    if (!Number.isFinite(parsed) || parsed <= 0) { setError('Enter a valid support amount.'); return; }
    setBusy(true); setError('');
    try {
      await api.createCase({ category, goalMinor: Math.round(parsed * 100), currency: currency.trim().toUpperCase(), countryCode: country.trim().toUpperCase(), publicIdentityMode: anonymous ? (alias.trim() ? 'ALIAS' : 'ANONYMOUS') : 'REAL_NAME', ...(anonymous && alias.trim() ? { publicDisplayName: alias.trim() } : {}) });
      onSuccess('Your request has been submitted for review.');
    } catch (e) { setError(e instanceof Error ? e.message : 'Could not submit the request.'); }
    finally { setBusy(false); }
  };
  return <View style={styles.formCard}><Text style={styles.formIntro}>Tell us what kind of support is needed and the target amount. Requests are reviewed before they appear publicly.</Text>
    <Text style={styles.fieldLabel}>Community group</Text><View style={styles.categoryGrid}>{categories.map(([key, label]) => <Pressable key={key} onPress={() => setCategory(key)} style={[styles.categoryOption, category === key && styles.categoryOptionSelected]}><Text style={[styles.categoryOptionText, category === key && styles.categoryOptionTextSelected]}>{label}</Text></Pressable>)}</View>
    <Field label="Amount needed" value={amount} onChangeText={setAmount} placeholder="For example, 2500" keyboardType="decimal-pad" />
    <View style={styles.inlineFields}><View style={styles.flex}><Field label="Currency" value={currency} onChangeText={setCurrency} placeholder="KES" autoCapitalize="characters" /></View><View style={styles.flex}><Field label="Country code" value={country} onChangeText={setCountry} placeholder="KE" autoCapitalize="characters" /></View></View>
    <Pressable onPress={() => setAnonymous(!anonymous)} style={styles.toggleRow}><View style={[styles.checkbox, anonymous && styles.checkboxOn]}><Text style={styles.checkText}>{anonymous ? '✓' : ''}</Text></View><View style={styles.flex}><Text style={styles.toggleTitle}>Protect my public identity</Text><Text style={styles.toggleBody}>Your full name stays private on public requests.</Text></View></Pressable>
    {anonymous && <Field label="Public name (optional)" value={alias} onChangeText={setAlias} placeholder="Use a first name or alias" />}
    {error ? <Text accessibilityRole="alert" style={styles.error}>{error}</Text> : null}
    <View style={styles.inlineFields}><View style={styles.flex}><Action title="Cancel" secondary onPress={onCancel} /></View><View style={styles.flex}><Action title={busy ? 'Submitting…' : 'Submit request'} disabled={busy} onPress={save} /></View></View>
  </View>;
}

function MessagesScreen({ user, onOpen }: { user: User; onOpen: (thread: Thread) => void }) {
  const [items, setItems] = useState<Thread[]>([]); const [loading, setLoading] = useState(true); const [error, setError] = useState('');
  const load = useCallback(async () => { setError(''); try { setItems(await api.threads()); } catch (e) { setError(e instanceof Error ? e.message : 'Could not load messages.'); } finally { setLoading(false); } }, []);
  useEffect(() => { void load(); }, [load]);
  if (error) return <ErrorCard message={error} onRetry={load} />;
  if (loading) return <LoadingCard />;
  if (!items.length) return <EmptyCard title="Your conversations will appear here" body="Offer help on a request to start a private conversation." />;
  return <View>{items.map((thread) => { const other = thread.participants?.find((participant: any) => participant.id !== user.id)?.name || 'Helpi member'; return <Pressable key={thread.id} onPress={() => onOpen(thread)} style={styles.threadCard}><View style={styles.avatar}><Text style={styles.avatarText}>{initials(other)}</Text></View><View style={styles.threadBody}><Text style={styles.threadTitle}>{thread.case?.title || 'Community request'}</Text><Text style={styles.threadPerson}>{other}</Text><Text numberOfLines={1} style={styles.threadPreview}>{thread.messages?.[0]?.body || 'Open conversation'}</Text></View><Text style={styles.chevron}>›</Text></Pressable>; })}</View>;
}

function ThreadScreen({ thread, user, onBack }: { thread: Thread; user: User; onBack: () => void }) {
  const [items, setItems] = useState<any[]>([]); const [body, setBody] = useState(''); const [loading, setLoading] = useState(true); const [sending, setSending] = useState(false); const [error, setError] = useState('');
  const load = useCallback(async () => { setError(''); try { setItems(await api.threadMessages(thread.id)); } catch (e) { setError(e instanceof Error ? e.message : 'Could not load messages.'); } finally { setLoading(false); } }, [thread.id]);
  useEffect(() => { void load(); }, [load]);
  const send = async () => { const text = body.trim(); if (!text || sending) return; setSending(true); setError(''); try { await api.sendMessage(thread.id, text); setBody(''); await load(); } catch (e) { setError(e instanceof Error ? e.message : 'Message was not sent.'); } finally { setSending(false); } };
  return <View style={styles.threadPage}><Pressable onPress={onBack} style={styles.backButton}><Text style={styles.backText}>‹  Back to messages</Text></Pressable>{error ? <ErrorCard message={error} onRetry={load} /> : loading ? <LoadingCard /> : <ScrollView style={styles.chatList} contentContainerStyle={styles.chatInner}>{items.map((item) => { const mine = item.senderId === user.id; return <View key={item.id} style={[styles.messageBubble, mine ? styles.messageMine : styles.messageOther]}><Text style={[styles.messageText, mine && styles.messageMineText]}>{item.body}</Text><Text style={[styles.messageTime, mine && styles.messageMineTime]}>{item.createdAt ? new Date(item.createdAt).toLocaleString() : ''}</Text></View>; })}</ScrollView>}<View style={styles.sendRow}><TextInput value={body} onChangeText={setBody} placeholder="Write a message" multiline style={styles.sendInput} maxLength={4000} /><Pressable accessibilityRole="button" onPress={send} disabled={sending || !body.trim()} style={[styles.sendButton, (!body.trim() || sending) && styles.disabled]}><Text style={styles.sendButtonText}>Send</Text></Pressable></View></View>;
}

function ProfileScreen({ user, onMine, onNotifications, onSafety, onSignOut }: { user: User; onMine: () => void; onNotifications: () => void; onSafety: () => void; onSignOut: () => void }) {
  const display = user.publicIdentityMode === 'ANONYMOUS' ? 'Anonymous member' : user.publicAlias || user.name || 'Helpi member';
  return <View><View style={styles.profileCard}><View style={styles.profileAvatar}><Text style={styles.profileAvatarText}>{initials(display)}</Text></View><Text style={styles.profileName}>{display}</Text><Text style={styles.profileEmail}>{user.email}</Text><Text style={styles.profileLocation}>{user.countryCode || 'Community member'}</Text></View>
    <Text style={styles.sectionTitle}>Your account</Text><ProfileLink title="My support requests" subtitle="Track your requests and their review status" icon="⌂" onPress={onMine} /><ProfileLink title="Notifications" subtitle="Updates about your account and requests" icon="♧" onPress={onNotifications} /><ProfileLink title="Privacy and safety" subtitle="Safety tips and reporting options" icon="◇" onPress={onSafety} />
    <Action title="Sign out" secondary onPress={onSignOut} /><Text style={styles.versionLine}>Helpi community · Version 3.0</Text>
  </View>;
}

function SafetyScreen() {
  const [type, setType] = useState('SAFEGUARDING'); const [description, setDescription] = useState('');
  const [busy, setBusy] = useState(false); const [notice, setNotice] = useState(''); const [error, setError] = useState('');
  const submit = async () => { if (description.trim().length < 10) { setError('Please share at least 10 characters so the safety team can review it.'); return; } setBusy(true); setError(''); setNotice(''); try { await api.report(type, description.trim()); setNotice('Your report was sent for review.'); setDescription(''); } catch (e) { setError(e instanceof Error ? e.message : 'Could not send your report.'); } finally { setBusy(false); } };
  return <View><View style={styles.safetyCard}><Text style={styles.sectionTitle}>Stay safe on Helpi</Text><Text style={styles.safetyTip}>• Keep conversations on Helpi so you can report concerns.</Text><Text style={styles.safetyTip}>• Never share your password, verification code, or payment PIN.</Text><Text style={styles.safetyTip}>• Meet in a safe public place and bring someone you trust.</Text><Text style={styles.safetyTip}>• Do not send money to unlock a request or account.</Text></View><View style={styles.formCard}><Text style={styles.sectionTitle}>Report a concern</Text><Text style={styles.formIntro}>A moderator will review reports. For immediate danger, contact local emergency services.</Text><View style={styles.categoryGrid}>{[['SAFEGUARDING','Safety concern'],['SCAM','Possible scam'],['HARASSMENT','Harassment'],['OTHER','Other']].map(([key,label]) => <Pressable key={key} onPress={() => setType(key)} style={[styles.categoryOption, type === key && styles.categoryOptionSelected]}><Text style={[styles.categoryOptionText, type === key && styles.categoryOptionTextSelected]}>{label}</Text></Pressable>)}</View><Field label="What happened?" value={description} onChangeText={setDescription} placeholder="Share the details needed to review your report" multiline />{error ? <Text accessibilityRole="alert" style={styles.error}>{error}</Text> : null}{notice ? <Text style={styles.noticeText}>{notice}</Text> : null}<Action title={busy ? 'Sending report…' : 'Send report'} disabled={busy} onPress={submit} /></View></View>;
}
function ProfileLink({ title, subtitle, icon, onPress }: { title: string; subtitle: string; icon: string; onPress: () => void }) { return <Pressable onPress={onPress} style={styles.profileLink}><Text style={styles.profileLinkIcon}>{icon}</Text><View style={styles.flex}><Text style={styles.profileLinkTitle}>{title}</Text><Text style={styles.profileLinkSubtitle}>{subtitle}</Text></View><Text style={styles.chevron}>›</Text></Pressable>; }

function MyRequests({ onCreate }: { onCreate: () => void }) {
  const [items, setItems] = useState<HelpCase[]>([]); const [loading, setLoading] = useState(true); const [error, setError] = useState('');
  const load = useCallback(async () => { setError(''); try { setItems(await api.mine()); } catch (e) { setError(e instanceof Error ? e.message : 'Could not load your requests.'); } finally { setLoading(false); } }, []);
  useEffect(() => { void load(); }, [load]);
  if (error) return <ErrorCard message={error} onRetry={load} />;
  if (loading) return <LoadingCard />;
  return items.length ? <View>{items.map((item) => <CaseCard key={item.id} item={item} onPress={() => undefined} />)}</View> : <EmptyCard title="You have not posted a request" body="Share what support is needed and we’ll guide you through the next steps." action="Post a request" onAction={onCreate} />;
}

function NotificationsScreen({ onBack }: { onBack: () => void }) {
  const [items, setItems] = useState<any[]>([]); const [loading, setLoading] = useState(true); const [error, setError] = useState('');
  const load = useCallback(async () => { setError(''); try { setItems(await api.notifications()); } catch (e) { setError(e instanceof Error ? e.message : 'Could not load notifications.'); } finally { setLoading(false); } }, []);
  useEffect(() => { void load(); }, [load]);
  if (loading) return <LoadingCard />;
  if (error) return <ErrorCard message={error} onRetry={load} />;
  return items.length ? <View>{items.map((item) => <View key={item.id} style={styles.notificationCard}><Text style={styles.notificationTitle}>{item.title || item.type?.replaceAll('_', ' ') || 'Helpi update'}</Text><Text style={styles.notificationBody}>{item.body || item.message || 'There is an update to your account.'}</Text>{item.createdAt && <Text style={styles.notificationDate}>{new Date(item.createdAt).toLocaleDateString()}</Text>}</View>)}</View> : <EmptyCard title="You’re all caught up" body="New updates about your account will appear here." action="Back to profile" onAction={onBack} />;
}

function SectionHeading({ title, action, onPress }: { title: string; action?: string; onPress?: () => void }) { return <View style={styles.sectionHeading}><Text style={styles.sectionTitle}>{title}</Text>{action && <Pressable onPress={onPress}><Text style={styles.sectionAction}>{action}  ›</Text></Pressable>}</View>; }
function LoadingCard() { return <View style={styles.stateCard}><ActivityIndicator color={orange} /><Text style={styles.stateText}>Loading…</Text></View>; }
function EmptyCard({ title, body, action, onAction }: { title: string; body: string; action?: string; onAction?: () => void }) { return <View style={styles.stateCard}><Text style={styles.emptyGlyph}>♡</Text><Text style={styles.stateTitle}>{title}</Text><Text style={styles.stateText}>{body}</Text>{action && onAction && <Action title={action} onPress={onAction} />}</View>; }
function ErrorCard({ message, onRetry }: { message: string; onRetry: () => void }) { return <View style={[styles.stateCard, styles.errorCard]}><Text style={styles.errorTitle}>We couldn’t load this</Text><Text style={styles.stateText}>{message}</Text><Action title="Try again" secondary onPress={onRetry} /></View>; }

const styles = StyleSheet.create({
  app: { flex: 1, minHeight: '100%', backgroundColor: canvas, color: ink } as any,
  loading: { flex: 1, minHeight: '100%', alignItems: 'center', justifyContent: 'center', gap: 12, backgroundColor: canvas } as any,
  loadingText: { color: muted, fontSize: 14, marginTop: 8 }, appFrame: { flex: 1, flexDirection: 'column', minHeight: '100%' } as any,
  appFrameWide: { flexDirection: 'row', maxWidth: 1500, width: '100%', alignSelf: 'center' }, rail: { width: 244, backgroundColor: '#fff', borderRightWidth: 1, borderColor: border, paddingHorizontal: 18, paddingVertical: 28 },
  main: { flex: 1, minWidth: 0, minHeight: '100%', backgroundColor: canvas } as any,
  brand: { flexDirection: 'row', alignItems: 'center', gap: 10 }, brandName: { color: navy, fontSize: 21, fontWeight: '900' },
  railCaption: { color: '#9aa2af', letterSpacing: 1.1, fontSize: 10, fontWeight: '800', marginTop: 38, marginBottom: 12 }, railGrow: { flex: 1 }, railFoot: { color: muted, fontSize: 12, padding: 12 },
  topBar: { height: 68, paddingHorizontal: 22, backgroundColor: '#fff', borderBottomColor: border, borderBottomWidth: 1, flexDirection: 'row', alignItems: 'center', gap: 18 }, topTitle: { color: navy, fontSize: 17, fontWeight: '800', flex: 1 }, bell: { width: 42, height: 42, borderRadius: 21, backgroundColor: '#fff7ef', alignItems: 'center', justifyContent: 'center' }, bellText: { color: orange, fontSize: 21, fontWeight: '800' },
  content: { flex: 1 } as any, contentInner: { paddingHorizontal: 18, paddingTop: 20, paddingBottom: 30, width: '100%', maxWidth: 760, alignSelf: 'center' } as any, contentInnerWide: { paddingHorizontal: 34, paddingTop: 30, maxWidth: 940 },
  bottomNav: { minHeight: 66, flexDirection: 'row', alignItems: 'center', justifyContent: 'space-around', backgroundColor: '#fff', borderTopWidth: 1, borderTopColor: border, paddingBottom: Platform.OS === 'android' ? 8 : 4 }, navButton: { alignItems: 'center', justifyContent: 'center', gap: 2, borderRadius: 13, minWidth: 68, minHeight: 54, paddingHorizontal: 10 }, navHorizontal: { width: '100%', minHeight: 48, flexDirection: 'row', justifyContent: 'flex-start', gap: 13, paddingHorizontal: 14, marginBottom: 5 }, navSelected: { backgroundColor: '#fff0e3' }, navIcon: { color: '#818a98', fontSize: 22, lineHeight: 25 }, navIconSelected: { color: orange }, navLabel: { color: muted, fontSize: 10, fontWeight: '600' }, navLabelSelected: { color: '#a34a00', fontWeight: '800' }, desktopAction: { paddingHorizontal: 34, paddingBottom: 24 },
  welcomeCard: { backgroundColor: navy, borderRadius: 23, padding: 23, marginBottom: 29, overflow: 'hidden' }, welcomeKicker: { color: '#ffbc7c', fontWeight: '800', fontSize: 12, textTransform: 'uppercase', letterSpacing: .8 }, welcomeTitle: { color: '#fff', fontSize: 30, lineHeight: 37, fontWeight: '900', marginTop: 12 }, welcomeBody: { color: '#dbe3ef', fontSize: 15, lineHeight: 22, maxWidth: 490, marginTop: 7 }, welcomeActions: { flexDirection: 'row', flexWrap: 'wrap', gap: 10, marginTop: 20 }, action: { minHeight: 46, paddingHorizontal: 18, paddingVertical: 12, borderRadius: 13, backgroundColor: orange, alignItems: 'center', justifyContent: 'center' }, actionText: { color: '#fff', fontSize: 14, fontWeight: '800', textAlign: 'center' }, actionSecondary: { backgroundColor: '#fff', borderColor: border, borderWidth: 1 }, actionSecondaryText: { color: navy }, disabled: { opacity: .55 }, pressed: { opacity: .75 },
  sectionHeading: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 2, marginBottom: 13 }, sectionTitle: { color: navy, fontSize: 18, fontWeight: '800' }, sectionAction: { color: '#a94c00', fontSize: 13, fontWeight: '800' },
  caseCard: { backgroundColor: '#fff', borderColor: border, borderWidth: 1, borderRadius: 18, padding: 16, marginBottom: 12 }, caseTop: { flexDirection: 'row', gap: 12, alignItems: 'center' }, caseIcon: { width: 43, height: 43, borderRadius: 14, alignItems: 'center', justifyContent: 'center', backgroundColor: '#fff0e3' }, caseIconText: { color: orange, fontSize: 19, fontWeight: '900' }, caseHeadline: { flex: 1 }, caseCategory: { color: '#ac570f', fontSize: 11, fontWeight: '800', textTransform: 'uppercase', letterSpacing: .55 }, caseTitle: { color: navy, fontSize: 15, lineHeight: 20, fontWeight: '800', marginTop: 3 }, chevron: { color: '#98a1af', fontSize: 25, paddingHorizontal: 2 }, caseMeta: { color: muted, fontSize: 12, marginTop: 13 }, caseBottom: { flexDirection: 'row', alignItems: 'center', justifyContent: 'space-between', marginTop: 16, paddingTop: 13, borderTopWidth: 1, borderTopColor: '#f3eee9' }, amount: { color: navy, fontSize: 18, fontWeight: '900' }, amountCaption: { color: muted, fontSize: 11, marginTop: 1 }, smallAction: { paddingVertical: 9, paddingHorizontal: 14, backgroundColor: '#fff2e6', borderRadius: 10 }, smallActionText: { color: '#a44800', fontSize: 12, fontWeight: '800' },
  caseDetail: { backgroundColor: '#fff', borderColor: border, borderWidth: 1, borderRadius: 20, padding: 20, alignItems: 'flex-start' }, detailTitle: { color: navy, fontSize: 24, fontWeight: '900', marginTop: 8 }, detailAmount: { width: '100%', borderTopWidth: 1, borderBottomWidth: 1, borderColor: border, paddingVertical: 15, marginVertical: 16 }, detailAmountValue: { color: navy, fontSize: 24, fontWeight: '900' }, safetyNote: { color: muted, fontSize: 11, lineHeight: 17, marginTop: 15 },
  hintCard: { flexDirection: 'row', gap: 12, backgroundColor: '#f4f7fb', padding: 16, borderRadius: 15, marginTop: 14 }, hintIcon: { color: '#3c648f', fontSize: 21 }, hintTitle: { color: navy, fontSize: 13, fontWeight: '800' }, hintCopy: { color: muted, fontSize: 12, lineHeight: 18, marginTop: 3 }, flex: { flex: 1 },
  safetyCard: { backgroundColor: '#f2f6fb', borderRadius: 17, padding: 17, marginBottom: 15 }, safetyTip: { color: muted, fontSize: 13, lineHeight: 20, marginTop: 9 },
  screenLead: { color: muted, fontSize: 14, lineHeight: 21, marginBottom: 15 }, searchRow: { flexDirection: 'row', alignItems: 'center', height: 50, borderRadius: 13, borderColor: border, borderWidth: 1, backgroundColor: '#fff', paddingLeft: 12, marginBottom: 14 }, searchIcon: { color: muted, fontSize: 22, marginRight: 5 }, searchInput: { flex: 1, fontSize: 14, color: ink, outlineStyle: 'none' as any }, searchGo: { height: 40, minWidth: 70, alignItems: 'center', justifyContent: 'center', backgroundColor: navy, borderRadius: 10, marginHorizontal: 5 }, searchGoText: { color: '#fff', fontWeight: '700', fontSize: 12 }, chipRow: { flexDirection: 'row', gap: 8, paddingBottom: 14 }, chip: { borderWidth: 1, borderColor: border, backgroundColor: '#fff', borderRadius: 20, paddingVertical: 7, paddingHorizontal: 12 }, chipText: { color: navy, fontSize: 12, fontWeight: '600' },
  stateCard: { backgroundColor: '#fff', borderColor: border, borderWidth: 1, borderRadius: 18, padding: 22, alignItems: 'center', marginVertical: 12, gap: 10 }, stateTitle: { color: navy, fontSize: 17, textAlign: 'center', fontWeight: '800' }, stateText: { color: muted, fontSize: 13, textAlign: 'center', lineHeight: 19, maxWidth: 440 }, emptyGlyph: { color: orange, fontSize: 31 }, errorCard: { borderColor: '#f3c5b3', backgroundColor: '#fff9f6' }, errorTitle: { color: '#9e321e', fontSize: 16, fontWeight: '800' }, error: { color: '#a5261b', fontSize: 13, lineHeight: 19, padding: 12, borderRadius: 10, backgroundColor: '#fff0ed', marginBottom: 10 },
  field: { gap: 7, marginBottom: 15 }, fieldLabel: { color: navy, fontSize: 13, fontWeight: '700', marginBottom: 7 }, input: { minHeight: 47, borderWidth: 1, borderColor: border, borderRadius: 12, backgroundColor: '#fff', paddingHorizontal: 13, color: ink, fontSize: 15, outlineStyle: 'none' as any }, multiline: { minHeight: 90, textAlignVertical: 'top', paddingTop: 12 },
  authPage: { flex: 1, minHeight: '100%', backgroundColor: '#fff5ec' } as any, authScroll: { minHeight: '100%', justifyContent: 'center', alignItems: 'center', paddingHorizontal: 18, paddingVertical: 28 } as any, authCard: { width: '100%', maxWidth: 480, backgroundColor: '#fff', borderColor: '#f0dfd1', borderWidth: 1, borderRadius: 24, padding: 25, shadowColor: '#7b4b27', shadowOpacity: .08, shadowRadius: 24, elevation: 2 }, authCardWide: { padding: 34 }, eyebrow: { color: '#bc5200', letterSpacing: 1.2, fontSize: 11, fontWeight: '900' }, authTitle: { color: navy, fontSize: 31, fontWeight: '900', marginTop: 10 }, authCopy: { color: muted, fontSize: 14, lineHeight: 21, marginTop: 8, marginBottom: 24 }, switchAuth: { alignSelf: 'center', padding: 14 }, switchAuthText: { color: '#a44b00', fontSize: 13, fontWeight: '800' }, adminLinkText: { color: muted, fontSize: 12, fontWeight: '700' }, privacyLine: { color: '#9199a5', fontSize: 11, textAlign: 'center', marginTop: 8 },
  notice: { backgroundColor: '#eaf8ef', padding: 12, marginHorizontal: 18, marginTop: 10, borderRadius: 11 }, noticeText: { color: '#24663f', fontSize: 13, fontWeight: '700' },
  formCard: { backgroundColor: '#fff', borderColor: border, borderWidth: 1, borderRadius: 18, padding: 17 }, formIntro: { color: muted, fontSize: 13, lineHeight: 20, marginBottom: 20 }, categoryGrid: { flexDirection: 'row', flexWrap: 'wrap', gap: 8, marginBottom: 19 }, categoryOption: { borderWidth: 1, borderColor: border, backgroundColor: '#fff', borderRadius: 20, paddingHorizontal: 11, paddingVertical: 8 }, categoryOptionSelected: { borderColor: orange, backgroundColor: '#fff0e3' }, categoryOptionText: { color: muted, fontSize: 11, fontWeight: '600' }, categoryOptionTextSelected: { color: '#914000', fontWeight: '800' }, inlineFields: { flexDirection: 'row', gap: 10 }, toggleRow: { flexDirection: 'row', alignItems: 'center', gap: 12, padding: 12, backgroundColor: '#f8fafc', borderRadius: 12, marginBottom: 17 }, checkbox: { width: 23, height: 23, borderWidth: 1, borderColor: '#bcc4d0', borderRadius: 7, alignItems: 'center', justifyContent: 'center' }, checkboxOn: { borderColor: orange, backgroundColor: orange }, checkText: { color: '#fff', fontWeight: '900', fontSize: 14 }, toggleTitle: { color: navy, fontSize: 13, fontWeight: '800' }, toggleBody: { color: muted, fontSize: 11, lineHeight: 16, marginTop: 3 },
  threadCard: { flexDirection: 'row', alignItems: 'center', gap: 12, backgroundColor: '#fff', borderWidth: 1, borderColor: border, borderRadius: 15, padding: 14, marginBottom: 10 }, avatar: { width: 42, height: 42, borderRadius: 21, backgroundColor: '#fff0e3', alignItems: 'center', justifyContent: 'center' }, avatarText: { color: '#a54c00', fontWeight: '800' }, threadBody: { flex: 1 }, threadTitle: { color: navy, fontSize: 14, fontWeight: '800' }, threadPerson: { color: '#a44b00', fontSize: 11, fontWeight: '700', marginTop: 3 }, threadPreview: { color: muted, fontSize: 12, marginTop: 4 },
  threadPage: { flex: 1, minHeight: 420 }, backButton: { alignSelf: 'flex-start', paddingVertical: 9, paddingHorizontal: 4 }, backText: { color: '#a44b00', fontWeight: '800' }, chatList: { flex: 1, maxHeight: 530 } as any, chatInner: { gap: 9, paddingVertical: 8 }, messageBubble: { maxWidth: '84%', paddingHorizontal: 13, paddingVertical: 10, borderRadius: 15 }, messageMine: { alignSelf: 'flex-end', backgroundColor: navy, borderBottomRightRadius: 4 }, messageOther: { alignSelf: 'flex-start', backgroundColor: '#fff', borderColor: border, borderWidth: 1, borderBottomLeftRadius: 4 }, messageText: { color: ink, fontSize: 14, lineHeight: 20 }, messageMineText: { color: '#fff' }, messageTime: { color: muted, fontSize: 9, marginTop: 5, textAlign: 'right' }, messageMineTime: { color: '#ccd5e1' }, sendRow: { flexDirection: 'row', gap: 8, alignItems: 'flex-end', paddingTop: 10 }, sendInput: { flex: 1, minHeight: 46, maxHeight: 100, borderWidth: 1, borderColor: border, borderRadius: 13, paddingHorizontal: 12, paddingTop: 12, backgroundColor: '#fff', color: ink, outlineStyle: 'none' as any }, sendButton: { minHeight: 44, backgroundColor: orange, paddingHorizontal: 16, borderRadius: 12, alignItems: 'center', justifyContent: 'center' }, sendButtonText: { color: '#fff', fontWeight: '800' },
  profileCard: { alignItems: 'center', backgroundColor: '#fff', borderRadius: 20, borderWidth: 1, borderColor: border, padding: 23, marginBottom: 26 }, profileAvatar: { width: 68, height: 68, borderRadius: 34, alignItems: 'center', justifyContent: 'center', backgroundColor: '#fff0e3', marginBottom: 12 }, profileAvatarText: { color: '#a54c00', fontWeight: '900', fontSize: 24 }, profileName: { color: navy, fontSize: 20, fontWeight: '900' }, profileEmail: { color: muted, fontSize: 13, marginTop: 4 }, profileLocation: { color: '#a44b00', fontSize: 12, fontWeight: '700', marginTop: 9 }, profileLink: { flexDirection: 'row', alignItems: 'center', gap: 13, padding: 15, backgroundColor: '#fff', borderWidth: 1, borderColor: border, borderRadius: 14, marginBottom: 9 }, profileLinkIcon: { width: 34, textAlign: 'center', color: orange, fontSize: 21 }, profileLinkTitle: { color: navy, fontSize: 14, fontWeight: '800' }, profileLinkSubtitle: { color: muted, fontSize: 11, lineHeight: 16, marginTop: 3 }, versionLine: { textAlign: 'center', color: '#9aa2af', fontSize: 11, marginTop: 20 },
  notificationCard: { backgroundColor: '#fff', borderColor: border, borderWidth: 1, borderRadius: 14, padding: 15, marginBottom: 10 }, notificationTitle: { color: navy, fontSize: 14, fontWeight: '800' }, notificationBody: { color: muted, fontSize: 13, lineHeight: 19, marginTop: 5 }, notificationDate: { color: '#929aa6', fontSize: 10, marginTop: 7 },
});

export default App;
