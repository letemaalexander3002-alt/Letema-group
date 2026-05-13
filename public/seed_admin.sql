-- ═══════════════════════════════════════════════════════════════════════
-- LETEMA GROUP — ADMIN SEED SCRIPT
-- ═══════════════════════════════════════════════════════════════════════
-- 
-- Admin Email: letemaalexander3002@gmail.com
-- Admin Password: Letema123@2026
--
-- HATUA ZA KUTUMIA:
-- ═══════════════════════════════════════════════════════════════════════
--
-- HATUA 1: Kwanza tengeneza user kwenye Supabase Dashboard
--          - Nenda: Authentication > Users > Add user > Create new user
--          - Email: letemaalexander3002@gmail.com
--          - Password: Letema123@2026
--          - Tick: Auto Confirm User
--          - Bonyeza: Create user
--
-- HATUA 2: Baada ya kuunda user, endesha SQL hii kwenye SQL Editor
--
-- ═══════════════════════════════════════════════════════════════════════

-- Set admin role and profile details
UPDATE profiles 
SET 
  role = 'super_admin',
  fname = 'Letema',
  lname = 'Alexander',
  country = 'Tanzania',
  preferred_language = 'sw',
  bio = 'Founder & CEO - Letema Group',
  is_active = true,
  updated_at = NOW()
WHERE email = 'letemaalexander3002@gmail.com';

-- Verify the update worked
SELECT 
  id,
  email,
  fname,
  lname,
  role,
  preferred_language,
  created_at
FROM profiles 
WHERE email = 'letemaalexander3002@gmail.com';

-- ═══════════════════════════════════════════════════════════════════════
-- IKIWA PROFILE HAIKUUNDWA AUTOMATICALLY:
-- ═══════════════════════════════════════════════════════════════════════
-- 
-- Kama trigger haijafanya kazi na profile haipo, tumia hii:
-- (Ondoa comment marks /* */ kuitumia)

/*
INSERT INTO profiles (
  id, 
  email, 
  fname, 
  lname, 
  country, 
  role, 
  preferred_language,
  bio,
  is_active
)
SELECT 
  id,
  email,
  'Letema',
  'Alexander',
  'Tanzania',
  'super_admin',
  'sw',
  'Founder & CEO - Letema Group',
  true
FROM auth.users 
WHERE email = 'letemaalexander3002@gmail.com'
ON CONFLICT (id) DO UPDATE SET
  role = 'super_admin',
  fname = 'Letema',
  lname = 'Alexander',
  bio = 'Founder & CEO - Letema Group',
  updated_at = NOW();
*/

-- ═══════════════════════════════════════════════════════════════════════
-- DONE! Admin amewekwa. Sasa unaweza kuingia kwenye letema_admin.html
-- ═══════════════════════════════════════════════════════════════════════
