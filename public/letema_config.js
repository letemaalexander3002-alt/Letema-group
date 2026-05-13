/**
 * LETEMA GROUP — GLOBAL CONFIGURATION
 * =====================================
 * Faili hii ina mipangilio yote ya pamoja kwa mfumo wa Letema Group:
 * - Supabase Integration (Database & Authentication)
 * - Global Translation System (Language Sync)
 * - Shared DB Helpers (CRUD operations)
 * 
 * Tumia: <script src="letema_config.js"></script> kwenye kila ukurasa
 */

(function(global) {
  'use strict';

  // ═══════════════════════════════════════════════════════════════
  // SUPABASE CONFIGURATION
  // ═══════════════════════════════════════════════════════════════
  const SUPABASE_URL = 'https://ubihrndpyutfpjefgdfb.supabase.co';
  const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InViaWhybmRweXV0ZnBqZWZnZGZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MDM2NTAsImV4cCI6MjA5NDE3OTY1MH0.u4daiVIzBw0lo_VoCMoHfUoKSSZ46QgWFgAXz_qR_qg';

  // Supabase REST API Headers
  const SUPA_HEADERS = {
    'apikey': SUPABASE_ANON_KEY,
    'Authorization': 'Bearer ' + SUPABASE_ANON_KEY,
    'Content-Type': 'application/json',
    'Prefer': 'return=representation'
  };

  // ═══════════════════════════════════════════════════════════════
  // SUPABASE CLIENT OBJECT
  // ═══════════════════════════════════════════════════════════════
  const LetemaSupabase = {
    url: SUPABASE_URL,
    key: SUPABASE_ANON_KEY,
    headers: SUPA_HEADERS,

    // ─── GET (Select) ───
    async get(table, params = '') {
      try {
        const url = `${SUPABASE_URL}/rest/v1/${table}?${params}&order=created_at.desc&limit=2000`;
        const response = await fetch(url, { headers: SUPA_HEADERS });
        if (!response.ok) {
          console.warn('[LetemaSupabase] GET failed:', response.status);
          return null;
        }
        return await response.json();
      } catch (error) {
        console.warn('[LetemaSupabase] GET error:', error.message);
        return null;
      }
    },

    // ─── POST (Insert) ───
    async post(table, data) {
      try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}`, {
          method: 'POST',
          headers: { ...SUPA_HEADERS, 'Prefer': 'return=representation' },
          body: JSON.stringify(data)
        });
        if (!response.ok) {
          console.warn('[LetemaSupabase] POST failed:', response.status);
          return null;
        }
        return await response.json();
      } catch (error) {
        console.warn('[LetemaSupabase] POST error:', error.message);
        return null;
      }
    },

    // ─── PATCH (Update) ───
    async patch(table, id, data) {
      try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}?id=eq.${id}`, {
          method: 'PATCH',
          headers: { ...SUPA_HEADERS, 'Prefer': 'return=representation' },
          body: JSON.stringify(data)
        });
        if (!response.ok) {
          console.warn('[LetemaSupabase] PATCH failed:', response.status);
          return null;
        }
        return await response.json();
      } catch (error) {
        console.warn('[LetemaSupabase] PATCH error:', error.message);
        return null;
      }
    },

    // ─── DELETE ───
    async delete(table, id) {
      try {
        const response = await fetch(`${SUPABASE_URL}/rest/v1/${table}?id=eq.${id}`, {
          method: 'DELETE',
          headers: { ...SUPA_HEADERS, 'Prefer': 'return=minimal' }
        });
        return response.ok;
      } catch (error) {
        console.warn('[LetemaSupabase] DELETE error:', error.message);
        return false;
      }
    },

    // ─── FIND (by column value) ───
    async find(table, column, value) {
      try {
        const url = `${SUPABASE_URL}/rest/v1/${table}?${column}=eq.${encodeURIComponent(value)}&limit=1`;
        const response = await fetch(url, { headers: SUPA_HEADERS });
        if (!response.ok) return null;
        const data = await response.json();
        return data && data.length > 0 ? data[0] : null;
      } catch (error) {
        console.warn('[LetemaSupabase] FIND error:', error.message);
        return null;
      }
    },

    // ─── COUNT ───
    async count(table, params = '') {
      try {
        const url = `${SUPABASE_URL}/rest/v1/${table}?${params}&select=id`;
        const response = await fetch(url, { 
          headers: { ...SUPA_HEADERS, 'Prefer': 'count=exact' }
        });
        const count = response.headers.get('content-range');
        if (count) {
          const match = count.match(/\/(\d+)/);
          return match ? parseInt(match[1], 10) : 0;
        }
        const data = await response.json();
        return Array.isArray(data) ? data.length : 0;
      } catch (error) {
        return 0;
      }
    }
  };

  // ═══════════════════════════════════════════════════════════════
  // SUPABASE AUTHENTICATION
  // ═══════════════════════════════════════════════════════════════
  const LetemaAuth = {
    SESSION_KEY: 'letema_auth_session',

    // ─── Sign Up (Email/Password) ───
    async signUp(email, password, metadata = {}) {
      try {
        const response = await fetch(`${SUPABASE_URL}/auth/v1/signup`, {
          method: 'POST',
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            email: email,
            password: password,
            data: metadata
          })
        });
        const data = await response.json();
        if (data.error) {
          return { error: data.error.message || 'Registration failed' };
        }
        // Auto-login after signup
        if (data.access_token) {
          this.saveSession(data);
        }
        return { user: data.user, session: data };
      } catch (error) {
        return { error: error.message };
      }
    },

    // ─── Sign In (Email/Password) ───
    async signIn(email, password) {
      try {
        const response = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
          method: 'POST',
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ email, password })
        });
        const data = await response.json();
        if (data.error) {
          return { error: data.error_description || data.error.message || 'Login failed' };
        }
        this.saveSession(data);
        return { user: data.user, session: data };
      } catch (error) {
        return { error: error.message };
      }
    },

    // ─── Sign Out ───
    async signOut() {
      const session = this.getSession();
      if (session && session.access_token) {
        try {
          await fetch(`${SUPABASE_URL}/auth/v1/logout`, {
            method: 'POST',
            headers: {
              'apikey': SUPABASE_ANON_KEY,
              'Authorization': 'Bearer ' + session.access_token
            }
          });
        } catch (e) { /* ignore */ }
      }
      sessionStorage.removeItem(this.SESSION_KEY);
      localStorage.removeItem(this.SESSION_KEY);
    },

    // ─── Get Current Session ───
    getSession() {
      try {
        const sess = sessionStorage.getItem(this.SESSION_KEY) || localStorage.getItem(this.SESSION_KEY);
        return sess ? JSON.parse(sess) : null;
      } catch {
        return null;
      }
    },

    // ─── Get Current User ───
    getUser() {
      const session = this.getSession();
      return session ? session.user : null;
    },

    // ─── Is Authenticated? ───
    isAuthenticated() {
      const session = this.getSession();
      if (!session || !session.access_token) return false;
      // Check expiry
      if (session.expires_at && Date.now() / 1000 > session.expires_at) {
        this.signOut();
        return false;
      }
      return true;
    },

    // ─── Save Session ───
    saveSession(data, remember = false) {
      const sessionData = JSON.stringify(data);
      sessionStorage.setItem(this.SESSION_KEY, sessionData);
      if (remember) {
        localStorage.setItem(this.SESSION_KEY, sessionData);
      }
    },

    // ─── Get Auth Headers ───
    getAuthHeaders() {
      const session = this.getSession();
      if (session && session.access_token) {
        return {
          ...SUPA_HEADERS,
          'Authorization': 'Bearer ' + session.access_token
        };
      }
      return SUPA_HEADERS;
    }
  };

  // ═══════════════════════════════════════════════════════════════
  // GLOBAL TRANSLATION SYSTEM
  // ═══════════════════════════════════════════════════════════════
  const LANGUAGE_KEY = 'letema_site_lang';
  
  const LANGUAGES = {
    en: { code: 'EN', flag: '\uD83C\uDDEC\uD83C\uDDE7', name: 'English', dir: 'ltr' },
    sw: { code: 'SW', flag: '\uD83C\uDDF9\uD83C\uDDFF', name: 'Kiswahili', dir: 'ltr' },
    fr: { code: 'FR', flag: '\uD83C\uDDEB\uD83C\uDDF7', name: 'Français', dir: 'ltr' },
    pt: { code: 'PT', flag: '\uD83C\uDDF5\uD83C\uDDF9', name: 'Português', dir: 'ltr' },
    ar: { code: 'AR', flag: '\uD83C\uDDF8\uD83C\uDDE6', name: '\u0627\u0644\u0639\u0631\u0628\u064A\u0629', dir: 'rtl' },
    zh: { code: 'ZH', flag: '\uD83C\uDDE8\uD83C\uDDF3', name: '\u4E2D\u6587', dir: 'ltr' }
  };

  // Global translations used across all pages
  const GLOBAL_TRANSLATIONS = {
    sw: {
      // Navigation
      'Dashboard': 'Dashibodi',
      'Members': 'Wanachama',
      'Leads': 'Wapendekezaji',
      'Logout': 'Ondoka',
      'Sign Out': 'Ondoka',
      'Settings': 'Mipangilio',
      'Profile': 'Wasifu',
      'Home': 'Nyumbani',
      'Resources': 'Rasilimali',
      'Back to Website': 'Rudi Tovuti',
      // Auth
      'Sign In': 'Ingia',
      'Sign Up': 'Jisajili',
      'Create Account': 'Tengeneza Akaunti',
      'Email': 'Barua Pepe',
      'Email Address': 'Anwani ya Barua Pepe',
      'Password': 'Nenosiri',
      'Confirm Password': 'Thibitisha Nenosiri',
      'First Name': 'Jina la Kwanza',
      'Last Name': 'Jina la Mwisho',
      'Phone': 'Simu',
      'WhatsApp Number': 'Nambari ya WhatsApp',
      'Country': 'Nchi',
      'Welcome Back': 'Karibu Tena',
      'Create your account': 'Tengeneza akaunti yako',
      // Common
      'Submit': 'Wasilisha',
      'Cancel': 'Ghairi',
      'Save': 'Hifadhi',
      'Delete': 'Futa',
      'Edit': 'Hariri',
      'Search': 'Tafuta',
      'Loading...': 'Inapakia...',
      'No data': 'Hakuna data',
      'Success': 'Imefanikiwa',
      'Error': 'Hitilafu',
      // Admin specific
      'Admin Panel': 'Paneli ya Msimamizi',
      'Total Leads': 'Jumla ya Wapendekezaji',
      'Total Members': 'Jumla ya Wanachama',
      'Directives Published': 'Maagizo Yaliyochapishwa',
      'Market Updates': 'Sasisho za Soko',
      'Daily Directives': 'Maagizo ya Kila Siku',
      'Conversion Analytics': 'Uchambuzi wa Ubadilishaji',
      'Lead Magnets': 'Vivutio vya Wapendekezaji',
      // Portal specific
      'Member Portal': 'Portal ya Mwanachama',
      'Inner Circle Member': 'Mwanachama wa Duara la Ndani',
      'Your Resources': 'Rasilimali Zako',
      'My Profile': 'Wasifu Wangu',
      // Toolkit specific
      'Conversion Toolkit': 'Zana za Ubadilishaji',
      'Ecosystem Map': 'Ramani ya Mfumo',
      'Recruitment Page': 'Ukurasa wa Kuajiri',
      'WhatsApp Kit': 'Kifaa cha WhatsApp'
    },
    fr: {
      'Dashboard': 'Tableau de Bord',
      'Members': 'Membres',
      'Leads': 'Prospects',
      'Logout': 'Déconnexion',
      'Sign Out': 'Déconnexion',
      'Settings': 'Paramètres',
      'Profile': 'Profil',
      'Sign In': 'Connexion',
      'Sign Up': 'Inscription',
      'Email Address': 'Adresse Email',
      'Password': 'Mot de Passe',
      'First Name': 'Prénom',
      'Last Name': 'Nom',
      'Welcome Back': 'Bienvenue',
      'Submit': 'Soumettre',
      'Save': 'Enregistrer',
      'Delete': 'Supprimer',
      'Search': 'Rechercher',
      'Loading...': 'Chargement...',
      'Success': 'Succès',
      'Error': 'Erreur'
    },
    pt: {
      'Dashboard': 'Painel',
      'Members': 'Membros',
      'Leads': 'Prospectos',
      'Logout': 'Sair',
      'Sign Out': 'Sair',
      'Settings': 'Configurações',
      'Profile': 'Perfil',
      'Sign In': 'Entrar',
      'Sign Up': 'Cadastrar',
      'Email Address': 'Endereço de Email',
      'Password': 'Senha',
      'First Name': 'Nome',
      'Last Name': 'Sobrenome',
      'Welcome Back': 'Bem-vindo de Volta',
      'Submit': 'Enviar',
      'Save': 'Salvar',
      'Delete': 'Excluir',
      'Search': 'Buscar',
      'Loading...': 'Carregando...',
      'Success': 'Sucesso',
      'Error': 'Erro'
    },
    ar: {
      'Dashboard': '\u0644\u0648\u062D\u0629 \u0627\u0644\u062A\u062D\u0643\u0645',
      'Members': '\u0627\u0644\u0623\u0639\u0636\u0627\u0621',
      'Leads': '\u0627\u0644\u0639\u0645\u0644\u0627\u0621 \u0627\u0644\u0645\u062D\u062A\u0645\u0644\u0648\u0646',
      'Logout': '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C',
      'Sign Out': '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062E\u0631\u0648\u062C',
      'Settings': '\u0627\u0644\u0625\u0639\u062F\u0627\u062F\u0627\u062A',
      'Profile': '\u0627\u0644\u0645\u0644\u0641 \u0627\u0644\u0634\u062E\u0635\u064A',
      'Sign In': '\u062A\u0633\u062C\u064A\u0644 \u0627\u0644\u062F\u062E\u0648\u0644',
      'Sign Up': '\u0625\u0646\u0634\u0627\u0621 \u062D\u0633\u0627\u0628',
      'Email Address': '\u0627\u0644\u0628\u0631\u064A\u062F \u0627\u0644\u0625\u0644\u0643\u062A\u0631\u0648\u0646\u064A',
      'Password': '\u0643\u0644\u0645\u0629 \u0627\u0644\u0645\u0631\u0648\u0631',
      'First Name': '\u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0623\u0648\u0644',
      'Last Name': '\u0627\u0644\u0627\u0633\u0645 \u0627\u0644\u0623\u062E\u064A\u0631',
      'Welcome Back': '\u0645\u0631\u062D\u0628\u0627 \u0628\u0639\u0648\u062F\u062A\u0643',
      'Submit': '\u0625\u0631\u0633\u0627\u0644',
      'Save': '\u062D\u0641\u0638',
      'Delete': '\u062D\u0630\u0641',
      'Search': '\u0628\u062D\u062B',
      'Loading...': '\u062C\u0627\u0631\u064A \u0627\u0644\u062A\u062D\u0645\u064A\u0644...',
      'Success': '\u0646\u062C\u0627\u062D',
      'Error': '\u062E\u0637\u0623'
    },
    zh: {
      'Dashboard': '\u4EEA\u8868\u677F',
      'Members': '\u4F1A\u5458',
      'Leads': '\u6F5C\u5728\u5BA2\u6237',
      'Logout': '\u9000\u51FA',
      'Sign Out': '\u9000\u51FA',
      'Settings': '\u8BBE\u7F6E',
      'Profile': '\u4E2A\u4EBA\u8D44\u6599',
      'Sign In': '\u767B\u5F55',
      'Sign Up': '\u6CE8\u518C',
      'Email Address': '\u7535\u5B50\u90AE\u4EF6',
      'Password': '\u5BC6\u7801',
      'First Name': '\u540D',
      'Last Name': '\u59D3',
      'Welcome Back': '\u6B22\u8FCE\u56DE\u6765',
      'Submit': '\u63D0\u4EA4',
      'Save': '\u4FDD\u5B58',
      'Delete': '\u5220\u9664',
      'Search': '\u641C\u7D22',
      'Loading...': '\u52A0\u8F7D\u4E2D...',
      'Success': '\u6210\u529F',
      'Error': '\u9519\u8BEF'
    }
  };

  const LetemaI18n = {
    LANGUAGE_KEY: LANGUAGE_KEY,
    LANGUAGES: LANGUAGES,
    translations: GLOBAL_TRANSLATIONS,

    // ─── Get Current Language ───
    getCurrentLang() {
      return localStorage.getItem(LANGUAGE_KEY) || 'en';
    },

    // ─── Set Language (Globally) ───
    setLang(lang) {
      if (!LANGUAGES[lang]) lang = 'en';
      localStorage.setItem(LANGUAGE_KEY, lang);
      document.documentElement.lang = lang;
      document.documentElement.dir = LANGUAGES[lang].dir;
      // Dispatch event for other components to react
      window.dispatchEvent(new CustomEvent('letema-lang-change', { detail: { lang } }));
      return lang;
    },

    // ─── Translate Text ───
    t(text, lang = null) {
      const currentLang = lang || this.getCurrentLang();
      if (currentLang === 'en') return text;
      const translations = this.translations[currentLang];
      return (translations && translations[text]) || text;
    },

    // ─── Get Language Info ───
    getLangInfo(lang = null) {
      const currentLang = lang || this.getCurrentLang();
      return LANGUAGES[currentLang] || LANGUAGES.en;
    },

    // ─── Sync Language to User Profile ───
    async syncToProfile() {
      const user = LetemaAuth.getUser();
      const lang = this.getCurrentLang();
      if (user && user.id) {
        await LetemaSupabase.patch('profiles', user.id, { preferred_language: lang });
      }
    },

    // ─── Load Language from Profile ───
    async loadFromProfile() {
      const user = LetemaAuth.getUser();
      if (user && user.id) {
        const profile = await LetemaSupabase.find('profiles', 'id', user.id);
        if (profile && profile.preferred_language) {
          this.setLang(profile.preferred_language);
          return profile.preferred_language;
        }
      }
      return this.getCurrentLang();
    }
  };

  // ═══════════════════════════════════════════════════════════════
  // LOCAL DB HELPER (Fallback & Cache)
  // ═══════════════════════════════════════════════════════════════
  const LetemaDB = {
    PREFIX: 'lg_',

    // ─── Get from localStorage ───
    get(key) {
      try {
        return JSON.parse(localStorage.getItem(this.PREFIX + key) || '[]');
      } catch {
        return [];
      }
    },

    // ─── Set to localStorage ───
    set(key, value) {
      try {
        localStorage.setItem(this.PREFIX + key, JSON.stringify(value));
      } catch (e) {
        console.warn('[LetemaDB] Storage error:', e.message);
      }
    },

    // ─── Push to array with Supabase sync ───
    async push(key, obj) {
      const arr = this.get(key);
      const item = { 
        ...obj, 
        id: Date.now(), 
        created_at: new Date().toISOString() 
      };
      arr.push(item);
      this.set(key, arr);
      // Sync to Supabase
      await LetemaSupabase.post(key, item);
      return arr;
    },

    // ─── Remove from array with Supabase sync ───
    async remove(key, id) {
      const arr = this.get(key).filter(x => x.id !== id);
      this.set(key, arr);
      await LetemaSupabase.delete(key, id);
      return arr;
    },

    // ─── Sync from Supabase to localStorage ───
    async syncFromCloud(tables = ['leads', 'members', 'profiles', 'directives', 'market_updates', 'magnet_requests', 'toolkit_leads']) {
      for (const table of tables) {
        try {
          const data = await LetemaSupabase.get(table);
          if (Array.isArray(data) && data.length > 0) {
            this.set(table, data);
          }
        } catch (e) {
          console.warn('[LetemaDB] Sync error for', table, e.message);
        }
      }
    }
  };

  // ═══════════════════════════════════════════════════════════════
  // AUTH GUARD (Protection for Admin & Portal pages)
  // ═══════════════════════════════════════════════════════════════
  const LetemaGuard = {
    // ─── Require Authentication ───
    requireAuth(redirectTo = 'index.html') {
      if (!LetemaAuth.isAuthenticated()) {
        window.location.href = redirectTo;
        return false;
      }
      return true;
    },

    // ─── Require Admin Role ───
    async requireAdmin(redirectTo = 'index.html') {
      if (!LetemaAuth.isAuthenticated()) {
        window.location.href = redirectTo;
        return false;
      }
      const user = LetemaAuth.getUser();
      if (!user) {
        window.location.href = redirectTo;
        return false;
      }
      // Check if user has admin role in profiles table
      const profile = await LetemaSupabase.find('profiles', 'id', user.id);
      if (!profile || profile.role !== 'admin') {
        alert('Access denied. Admin privileges required.');
        window.location.href = redirectTo;
        return false;
      }
      return true;
    }
  };

  // ═══════════════════════════════════════════════════════════════
  // UTILITY FUNCTIONS
  // ═══════════════════════════════════════════════════════════════
  const LetemaUtils = {
    // ─── Format Date ───
    formatDate(dateStr, locale = 'en-GB') {
      if (!dateStr) return '-';
      const date = new Date(dateStr);
      return date.toLocaleDateString(locale, { 
        day: '2-digit', 
        month: 'short', 
        year: 'numeric' 
      });
    },

    // ─── Format DateTime ───
    formatDateTime(dateStr, locale = 'en-GB') {
      if (!dateStr) return '-';
      const date = new Date(dateStr);
      return date.toLocaleString(locale, { 
        day: '2-digit', 
        month: 'short', 
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    },

    // ─── Get Initials ───
    getInitials(fname, lname) {
      const f = (fname || '').charAt(0).toUpperCase();
      const l = (lname || '').charAt(0).toUpperCase();
      return f + l || '?';
    },

    // ─── Show Toast ───
    showToast(icon, title, message, duration = 4000) {
      const toast = document.getElementById('toast');
      if (!toast) return;
      const tIcon = document.getElementById('tIcon');
      const tTitle = document.getElementById('tTitle');
      const tMsg = document.getElementById('tMsg');
      if (tIcon) tIcon.textContent = icon;
      if (tTitle) tTitle.textContent = title;
      if (tMsg) tMsg.textContent = message;
      toast.classList.add('show');
      setTimeout(() => toast.classList.remove('show'), duration);
    },

    // ─── Debounce ───
    debounce(func, wait) {
      let timeout;
      return function executedFunction(...args) {
        const later = () => {
          clearTimeout(timeout);
          func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
      };
    },

    // ─── Generate UUID ───
    uuid() {
      return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        const r = Math.random() * 16 | 0;
        const v = c === 'x' ? r : (r & 0x3 | 0x8);
        return v.toString(16);
      });
    }
  };

  // ═══════════════════════════════════════════════════════════════
  // EXPORT TO GLOBAL SCOPE
  // ═══════════════════════════════════════════════════════════════
  global.LetemaSupabase = LetemaSupabase;
  global.LetemaAuth = LetemaAuth;
  global.LetemaI18n = LetemaI18n;
  global.LetemaDB = LetemaDB;
  global.LetemaGuard = LetemaGuard;
  global.LetemaUtils = LetemaUtils;

  // Backward compatibility aliases
  global.supaGet = LetemaSupabase.get.bind(LetemaSupabase);
  global.supaPost = LetemaSupabase.post.bind(LetemaSupabase);
  global.supaDelete = LetemaSupabase.delete.bind(LetemaSupabase);
  global.supaFind = LetemaSupabase.find.bind(LetemaSupabase);

  // Initialize language on load
  document.addEventListener('DOMContentLoaded', function() {
    const lang = LetemaI18n.getCurrentLang();
    if (lang !== 'en') {
      document.documentElement.lang = lang;
      document.documentElement.dir = LANGUAGES[lang].dir;
    }
  });

  console.log('[Letema Config] Global configuration loaded successfully.');

})(typeof window !== 'undefined' ? window : this);
