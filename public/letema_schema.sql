-- ═══════════════════════════════════════════════════════════════════════
-- LETEMA GROUP — SUPABASE DATABASE SCHEMA
-- ═══════════════════════════════════════════════════════════════════════
-- 
-- Hii ni schema kamili ya database kwa mfumo wa Letema Group.
-- Inajumuisha:
--   1. profiles - Wasifu wa watumiaji (wanachama na admin)
--   2. leads - Wapendekezaji kutoka kwenye fomu za tovuti
--   3. members - Wanachama wa portal (deprecated - tumia profiles)
--   4. directives - Maagizo ya kila siku kutoka admin
--   5. market_updates - Sasisho za soko
--   6. magnet_requests - Maombi ya lead magnets (PDF downloads)
--   7. toolkit_leads - Leads kutoka Conversion Toolkit
--   8. whatsapp_scripts - Scripts za WhatsApp (editable by admin)
--   9. settings - Mipangilio ya mfumo
--
-- JINSI YA KUTUMIA:
-- 1. Fungua Supabase Dashboard: https://supabase.com/dashboard
-- 2. Chagua project yako
-- 3. Nenda SQL Editor
-- 4. Nakili na ubandike kodi hii yote
-- 5. Bonyeza "Run" kuendesha
--
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════
-- 1. PROFILES TABLE (Main User Table)
-- ═══════════════════════════════════════════════════════════════════════
-- Jedwali hili linashikilia wasifu wa watumiaji wote - wanachama na admin

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  fname TEXT NOT NULL,
  lname TEXT,
  phone TEXT,
  country TEXT,
  role TEXT DEFAULT 'member' CHECK (role IN ('member', 'admin', 'super_admin')),
  preferred_language TEXT DEFAULT 'en' CHECK (preferred_language IN ('en', 'sw', 'fr', 'pt', 'ar', 'zh')),
  avatar_url TEXT,
  bio TEXT,
  source TEXT DEFAULT 'portal', -- 'portal', 'admin', 'toolkit', 'website'
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_role ON profiles(role);

-- Trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════
-- 2. LEADS TABLE
-- ═══════════════════════════════════════════════════════════════════════
-- Wapendekezaji kutoka fomu za tovuti kuu

CREATE TABLE IF NOT EXISTS leads (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  fname TEXT NOT NULL,
  lname TEXT,
  email TEXT NOT NULL,
  phone TEXT,
  country TEXT,
  interest TEXT, -- 'Personal Mentorship', 'Global Ecosystem', 'Letema Shops', etc.
  goal TEXT,
  source TEXT DEFAULT 'website', -- 'website', 'portal', 'toolkit', 'referral'
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'qualified', 'converted', 'lost')),
  notes TEXT,
  assigned_to UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_created ON leads(created_at DESC);

CREATE TRIGGER leads_updated_at
  BEFORE UPDATE ON leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════
-- 3. MEMBERS TABLE (Legacy - for backward compatibility)
-- ═══════════════════════════════════════════════════════════════════════
-- Jedwali hili linatumika kwa compatibility na kodi ya zamani.
-- Kwa mfumo mpya, tumia 'profiles' badala yake.

CREATE TABLE IF NOT EXISTS members (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  fname TEXT NOT NULL,
  lname TEXT,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  country TEXT,
  pass TEXT, -- Hashed password (legacy, use Supabase Auth instead)
  source TEXT DEFAULT 'portal',
  is_active BOOLEAN DEFAULT true,
  ts TIMESTAMPTZ DEFAULT NOW(), -- Legacy column name
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_members_email ON members(email);

CREATE TRIGGER members_updated_at
  BEFORE UPDATE ON members
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════
-- 4. DIRECTIVES TABLE
-- ═══════════════════════════════════════════════════════════════════════
-- Maagizo ya kila siku kutoka admin kwa wanachama

CREATE TABLE IF NOT EXISTS directives (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  category TEXT DEFAULT 'Daily Directive' CHECK (category IN (
    'Daily Directive', 'Motivation', 'Sales Tip', 
    'Financial Education', 'Team Announcement', 'Strategy Update'
  )),
  pinned BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  author_id UUID REFERENCES profiles(id),
  ts TIMESTAMPTZ DEFAULT NOW(), -- Legacy column
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_directives_pinned ON directives(pinned DESC, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_directives_category ON directives(category);

CREATE TRIGGER directives_updated_at
  BEFORE UPDATE ON directives
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════
-- 5. MARKET UPDATES TABLE
-- ════════════════════════════════════════════════════════════════════���══
-- Sasisho za soko na biashara

CREATE TABLE IF NOT EXISTS market_updates (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  type TEXT DEFAULT 'QNET Update' CHECK (type IN (
    'QNET Update', 'Market Trend', 'Real Estate', 
    'E-Commerce', 'Business Opportunity', 'Financial News'
  )),
  source TEXT, -- URL ya chanzo
  is_published BOOLEAN DEFAULT true,
  author_id UUID REFERENCES profiles(id),
  ts TIMESTAMPTZ DEFAULT NOW(), -- Legacy column
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_market_updates_type ON market_updates(type);
CREATE INDEX IF NOT EXISTS idx_market_updates_created ON market_updates(created_at DESC);

CREATE TRIGGER market_updates_updated_at
  BEFORE UPDATE ON market_updates
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════
-- 6. MAGNET REQUESTS TABLE
-- ═══════════════════════════════════════════════════════════════════════
-- Maombi ya kupakua PDF/lead magnets

CREATE TABLE IF NOT EXISTS magnet_requests (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  email TEXT NOT NULL,
  name TEXT,
  resource TEXT NOT NULL, -- 'wealth_mindset', '3ms_money', 'startup_blueprint', 'quadrant_roadmap'
  downloaded BOOLEAN DEFAULT false,
  ts TIMESTAMPTZ DEFAULT NOW(), -- Legacy column
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_magnet_requests_email ON magnet_requests(email);
CREATE INDEX IF NOT EXISTS idx_magnet_requests_resource ON magnet_requests(resource);

-- ═══════════════════════════════════════════════════════════════════════
-- 7. TOOLKIT LEADS TABLE
-- ═══════════════════════════════════════════════════════════════════════
-- Leads kutoka Conversion Toolkit (Recruitment Page)

CREATE TABLE IF NOT EXISTS toolkit_leads (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  source TEXT DEFAULT 'recruitment_page', -- 'recruitment_page', 'ecosystem_map', 'whatsapp_kit'
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'contacted', 'interested', 'converted', 'lost')),
  notes TEXT,
  referred_by UUID REFERENCES profiles(id), -- Mwanachama aliyeshiriki link
  ts TIMESTAMPTZ DEFAULT NOW(), -- Legacy column
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_toolkit_leads_phone ON toolkit_leads(phone);
CREATE INDEX IF NOT EXISTS idx_toolkit_leads_status ON toolkit_leads(status);
CREATE INDEX IF NOT EXISTS idx_toolkit_leads_created ON toolkit_leads(created_at DESC);

CREATE TRIGGER toolkit_leads_updated_at
  BEFORE UPDATE ON toolkit_leads
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- ═══════════════════════════════════════════════════════════════════════
-- 8. WHATSAPP SCRIPTS TABLE
-- ═══════════════════════════════════════════════════════════════════════
-- Scripts za WhatsApp (zinazoweza kuhaririwa na admin)

CREATE TABLE IF NOT EXISTS whatsapp_scripts (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  stage TEXT NOT NULL CHECK (stage IN ('cold', 'warm', 'hot', 'follow_up', 'close')),
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  tip TEXT, -- Vidokezo vya kutumia script
  language TEXT DEFAULT 'sw' CHECK (language IN ('en', 'sw', 'fr', 'pt', 'ar', 'zh')),
  is_active BOOLEAN DEFAULT true,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_scripts_stage ON whatsapp_scripts(stage);
CREATE INDEX IF NOT EXISTS idx_whatsapp_scripts_language ON whatsapp_scripts(language);

CREATE TRIGGER whatsapp_scripts_updated_at
  BEFORE UPDATE ON whatsapp_scripts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Insert default WhatsApp scripts (Swahili)
INSERT INTO whatsapp_scripts (stage, title, body, tip, language, sort_order) VALUES
('cold', 'Hatua 1 — Mgeni Mpya (Cold)', 
'Habari! 👋

Nimekuona kwa [chanzo - Instagram/TikTok/referral] na nikaona unaweza kuwa mtu anayefaa kwa fursa ninayofanya kazi nayo.

Jina langu ni [JINA LAKO], na mimi ni sehemu ya timu inayosaidia watu Tanzania kujenga kipato cha ziada — bila kuhitaji mtaji mkubwa au tajriba.

Je, una dakika 2-3 nikueleze jinsi inavyofanya kazi? 🚀',
'💡 Usitume ujumbe mrefu sana mwanzoni. Omba tu ruhusa ya kueleza.', 'sw', 1),

('warm', 'Hatua 2 — Anavutiwa (Warm)',
'Nzuri sana! Naona una nia — hiyo ni ishara nzuri. 💪

Kwa ufupi sana:
- Tunafanya kazi na kampuni ya kimataifa inayoitwa QNET
- Unauza bidhaa za hali ya juu na kujenga timu yako mwenyewe
- Kipato kinaongezeka kadri timu inavyokua

Hatua ya kwanza ni kujifunza mfumo — nina video fupi ya dakika 10 inayoeleza kila kitu.

Je, nikutumie link? 📲',
'💡 Onyesha enthusiasm lakini usishinikize. Mwache achague mwenyewe.', 'sw', 2),

('hot', 'Hatua 3 — Tayari Kujiunga (Hot)',
'Hongera kwa kuamua kuchukua hatua! 🎉

Sasa hivi kuna mambo 3 unayohitaji:
1. Kujisajili kupitia link yetu rasmi
2. Kupata mafunzo ya awali (bure)
3. Kuanza kuuza na kujenga timu yako

Naweza kukusaidia kila hatua ya njia. Je, tuzungumze kwa simu au video call ili nikusaidie kuanza leo? 📞',
'💡 Mtu aliye hot anahitaji msaada wa moja kwa moja. Piga simu haraka iwezekanavyo.', 'sw', 3),

('follow_up', 'Hatua 4 — Follow-up',
'Habari tena! 👋

Nilikuwa nikifikiri kuhusu mazungumzo yetu ya awali. Je, umepata muda wa kuangalia video/habari niliyokutumia?

Sina shinikizo — nataka tu kuhakikisha hukukosa fursa hii. Timu yetu ina training wiki hii na itakuwa nzuri ukiwepo.

Je, kuna swali lolote unalohitaji jibu lake? Niko tayari kusaidia. 🤝',
'💡 Follow-up iwe ya kirafiki, sio ya kusumbua. Mpe nafasi ya kujibu.', 'sw', 4),

('close', 'Hatua 5 — Kumfunga (Close)',
'Sawa, tumezungumza mambo mengi na naona una nia ya kweli. 💯

Hatua ya mwisho ni rahisi:
👉 Bonyeza link hii kusajili: [LINK]
👉 Chagua package inayokufaa
👉 Mimi nitawasiliana nawe mara moja kukusaidia kuanza

Je, uko tayari kuanza safari yako ya uhuru wa kifedha leo? Nitakuongoza kila hatua. 🚀',
'💡 Wakati wa close, kuwa wa moja kwa moja. Omba uamuzi wazi.', 'sw', 5);

-- ═══════════════════════════════════════════════════════════════════════
-- 9. SETTINGS TABLE
-- ═══════════════════════════════════════════════════════════════════════
-- Mipangilio ya mfumo (EmailJS, URLs, etc.)

CREATE TABLE IF NOT EXISTS settings (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  key TEXT UNIQUE NOT NULL,
  value JSONB,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER settings_updated_at
  BEFORE UPDATE ON settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();

-- Insert default settings
INSERT INTO settings (key, value, description) VALUES
('emailjs_config', '{"serviceId": "", "templateId": "", "publicKey": ""}', 'EmailJS configuration for sending emails'),
('magnet_urls', '{"wealth_mindset": "", "3ms_money": "", "startup_blueprint": "", "quadrant_roadmap": ""}', 'URLs for downloadable lead magnets'),
('admin_password', '"LetemaAdmin2025"', 'Legacy admin password (use Supabase Auth instead)'),
('site_settings', '{"maintenanceMode": false, "allowRegistration": true}', 'General site settings');

-- ═══════════════════════════════════════════════════════════════════════
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ═══════════════════════════════════════════════════════════════════════

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE members ENABLE ROW LEVEL SECURITY;
ALTER TABLE directives ENABLE ROW LEVEL SECURITY;
ALTER TABLE market_updates ENABLE ROW LEVEL SECURITY;
ALTER TABLE magnet_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE toolkit_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE whatsapp_scripts ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings ENABLE ROW LEVEL SECURITY;

-- PROFILES: Users can read/update their own profile, admins can read all
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

CREATE POLICY "Enable insert for registration" ON profiles
  FOR INSERT WITH CHECK (true);

-- LEADS: Public can insert, only admins can view
CREATE POLICY "Anyone can create leads" ON leads
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can view all leads" ON leads
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

CREATE POLICY "Admins can update leads" ON leads
  FOR UPDATE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

CREATE POLICY "Admins can delete leads" ON leads
  FOR DELETE USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- MEMBERS: Public can insert, only admins can view
CREATE POLICY "Anyone can register as member" ON members
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Members can view own data" ON members
  FOR SELECT USING (email = (SELECT email FROM profiles WHERE id = auth.uid()));

CREATE POLICY "Admins can view all members" ON members
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- DIRECTIVES: Public read, admin write
CREATE POLICY "Anyone can view published directives" ON directives
  FOR SELECT USING (is_published = true);

CREATE POLICY "Admins can manage directives" ON directives
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- MARKET UPDATES: Public read, admin write
CREATE POLICY "Anyone can view published market updates" ON market_updates
  FOR SELECT USING (is_published = true);

CREATE POLICY "Admins can manage market updates" ON market_updates
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- MAGNET REQUESTS: Public insert, admin read
CREATE POLICY "Anyone can request magnets" ON magnet_requests
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can view magnet requests" ON magnet_requests
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- TOOLKIT LEADS: Public insert, admin read
CREATE POLICY "Anyone can submit toolkit leads" ON toolkit_leads
  FOR INSERT WITH CHECK (true);

CREATE POLICY "Admins can manage toolkit leads" ON toolkit_leads
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- WHATSAPP SCRIPTS: Members can read, admin can write
CREATE POLICY "Members can view active scripts" ON whatsapp_scripts
  FOR SELECT USING (is_active = true);

CREATE POLICY "Admins can manage scripts" ON whatsapp_scripts
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- SETTINGS: Admin only
CREATE POLICY "Admins can manage settings" ON settings
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role IN ('admin', 'super_admin'))
  );

-- ═══════════════════════════════════════════════════════════════════════
-- HELPER FUNCTION: Create profile on user signup
-- ═══════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, fname, lname, phone, country, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'fname', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'lname', ''),
    COALESCE(NEW.raw_user_meta_data->>'phone', ''),
    COALESCE(NEW.raw_user_meta_data->>'country', 'Tanzania'),
    'member'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to auto-create profile on signup
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ═══════════════════════════════════════════════════════════════════════
-- ADMIN SEED DATA
-- ═══════════════════════════════════════════════════════════════════════
-- 
-- HATUA ZA KUTENGENEZA ADMIN:
--
-- HATUA 1: Nenda Supabase Dashboard > Authentication > Users
-- HATUA 2: Bonyeza "Add user" > "Create new user"
-- HATUA 3: Weka taarifa hizi:
--          Email: letemaalexander3002@gmail.com
--          Password: Letema123@2026
--          Auto Confirm User: Yes (tick)
-- HATUA 4: Bonyeza "Create user"
-- HATUA 5: Endesha SQL ifuatayo kuweka admin role:
--
-- ═══════════════════════════════════════════════════════════════════════

-- Update admin role (run AFTER creating user in Auth dashboard)
-- Hii itafanya kazi baada ya trigger kuunda profile automatically

DO $$
DECLARE
  admin_user_id UUID;
BEGIN
  -- Find the user by email
  SELECT id INTO admin_user_id 
  FROM auth.users 
  WHERE email = 'letemaalexander3002@gmail.com';
  
  IF admin_user_id IS NOT NULL THEN
    -- Update profile to admin role
    UPDATE profiles 
    SET 
      role = 'super_admin',
      fname = 'Letema',
      lname = 'Alexander',
      country = 'Tanzania',
      preferred_language = 'sw',
      updated_at = NOW()
    WHERE id = admin_user_id;
    
    RAISE NOTICE 'Admin profile updated successfully for: letemaalexander3002@gmail.com';
  ELSE
    -- If user doesn't exist yet, create a placeholder profile
    -- (will be overwritten when user signs up)
    RAISE NOTICE 'User not found in auth.users. Please create user first via Authentication > Users > Add user';
  END IF;
END $$;

-- Alternative: Direct insert if profile doesn't exist after trigger
-- (Run this only if trigger failed to create profile)
/*
INSERT INTO profiles (id, email, fname, lname, country, role, preferred_language)
SELECT 
  id,
  'letemaalexander3002@gmail.com',
  'Letema',
  'Alexander', 
  'Tanzania',
  'super_admin',
  'sw'
FROM auth.users 
WHERE email = 'letemaalexander3002@gmail.com'
ON CONFLICT (id) DO UPDATE SET
  role = 'super_admin',
  fname = 'Letema',
  lname = 'Alexander',
  updated_at = NOW();
*/

-- ═══════════════════════════════════════════════════════════════════════
-- QUICK ADMIN SETUP (Alternative method using Supabase Auth API)
-- ═══════════════════════════════════════════════════════════════════════
--
-- Unaweza pia kutumia Supabase Management API kuunda user:
-- 
-- 1. Nenda Project Settings > API
-- 2. Nakili "service_role" key (SECRET - usishiriki)
-- 3. Tumia curl au Postman:
--
-- curl -X POST 'https://ubihrndpyutfpjefgdfb.supabase.co/auth/v1/admin/users' \
--   -H "apikey: YOUR_SERVICE_ROLE_KEY" \
--   -H "Authorization: Bearer YOUR_SERVICE_ROLE_KEY" \
--   -H "Content-Type: application/json" \
--   -d '{
--     "email": "letemaalexander3002@gmail.com",
--     "password": "Letema123@2026",
--     "email_confirm": true,
--     "user_metadata": {
--       "fname": "Letema",
--       "lname": "Alexander"
--     }
--   }'
--
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════
-- DONE!
-- ═══════════════════════════════════════════════════════════════════════
-- 
-- Baada ya kuendesha SQL hii:
-- 1. Tables 9 zitakuwa zimetengenezwa
-- 2. RLS policies zitakuwa zimewekwa
-- 3. Default WhatsApp scripts zitakuwa zimewekwa
-- 4. Auto-profile creation on signup itafanya kazi
--
-- MUHIMU: Fuata hatua za ADMIN SEED DATA hapo juu kuunda admin wa kwanza
--
-- ═══════════════════════════════════════════════════════════════════════
