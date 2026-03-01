-- =============================================
-- GT Athletics Trivia - Supabase Migration
-- Run this in the Supabase SQL Editor
-- =============================================

-- 1. Profiles table (linked to Supabase Auth)
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    display_name TEXT NOT NULL DEFAULT 'Yellow Jacket',
    points INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON profiles FOR ALL USING (true) WITH CHECK (true);

-- 2. Trivia Videos table
CREATE TABLE IF NOT EXISTS trivia_videos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    video_url TEXT NOT NULL,
    scheduled_time TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    activated_at TIMESTAMPTZ,
    question_text TEXT NOT NULL,
    correct_answer_index INTEGER NOT NULL DEFAULT 0,
    point_value INTEGER NOT NULL DEFAULT 10,
    time_limit_seconds INTEGER NOT NULL DEFAULT 30,
    uploaded_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE trivia_videos ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON trivia_videos FOR ALL USING (true) WITH CHECK (true);

-- 3. Answers table
CREATE TABLE IF NOT EXISTS answers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    video_id UUID NOT NULL REFERENCES trivia_videos(id) ON DELETE CASCADE,
    selected_index INTEGER NOT NULL,
    points_earned INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE answers ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON answers FOR ALL USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS rewards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    point_cost INTEGER NOT NULL,
    quantity_available INTEGER NOT NULL DEFAULT -1,
    category TEXT NOT NULL DEFAULT 'Merchandise',
    image_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON rewards FOR ALL USING (true) WITH CHECK (true);

CREATE TABLE IF NOT EXISTS redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    reward_id UUID NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
    reward_name TEXT NOT NULL,
    points_spent INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    redeemed_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE redemptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all" ON redemptions FOR ALL USING (true) WITH CHECK (true);

-- 6. Atomic point increment function (used by app)
CREATE OR REPLACE FUNCTION increment_points(user_id_input UUID, points_input INTEGER)
RETURNS VOID AS $$
BEGIN
    UPDATE profiles
    SET points = points + points_input
    WHERE id = user_id_input;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 7. Auto-create profile on signup (trigger)
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', 'Yellow Jacket')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists, then create
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();
