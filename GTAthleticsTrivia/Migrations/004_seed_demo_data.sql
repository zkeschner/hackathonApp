-- Seed Demo Data for GT Athletics Trivia App
-- Run this in Supabase SQL Editor

-- ============================================
-- DEMO USERS
-- Must create auth.users entries first (profiles FK references auth.users)
-- ============================================

-- Create auth users for demo profiles
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, confirmation_token, raw_app_meta_data, raw_user_meta_data)
VALUES
    ('a0000001-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'buzz.yellowjacket@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '30 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'george.burdell@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '28 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'ramblin.wreck@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '25 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'calvin.johnson@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '22 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'demaryius.thomas@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '20 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'joe.hamilton@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '18 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000007', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'chris.bosh@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '16 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000008', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'tashard.choice@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '14 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000009', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'derrick.morgan@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '12 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000010', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'morgan.burnett@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '10 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000011', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'dontae.harris@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '8 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000012', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'shaq.mason@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '6 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000013', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'adam.gotsis@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '5 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000014', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'marco.coleman@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '4 days', now(), '', '{"provider":"email","providers":["email"]}', '{}'),
    ('a0000001-0000-0000-0000-000000000015', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'pat.swilling@gatech.edu', crypt('demodemo', gen_salt('bf')), now(), now() - interval '3 days', now(), '', '{"provider":"email","providers":["email"]}', '{}')
ON CONFLICT (id) DO NOTHING;

-- Now insert profiles (matching auth user IDs)
INSERT INTO profiles (id, email, display_name, points, is_admin, created_at) VALUES
    ('a0000001-0000-0000-0000-000000000001', 'buzz.yellowjacket@gatech.edu', 'Buzz Yellowjacket', 1250, false, now() - interval '30 days'),
    ('a0000001-0000-0000-0000-000000000002', 'george.burdell@gatech.edu', 'George P. Burdell', 1100, false, now() - interval '28 days'),
    ('a0000001-0000-0000-0000-000000000003', 'ramblin.wreck@gatech.edu', 'Ramblin Wreck', 980, false, now() - interval '25 days'),
    ('a0000001-0000-0000-0000-000000000004', 'calvin.johnson@gatech.edu', 'Calvin Johnson', 875, false, now() - interval '22 days'),
    ('a0000001-0000-0000-0000-000000000005', 'demaryius.thomas@gatech.edu', 'Demaryius Thomas', 820, false, now() - interval '20 days'),
    ('a0000001-0000-0000-0000-000000000006', 'joe.hamilton@gatech.edu', 'Joe Hamilton', 755, false, now() - interval '18 days'),
    ('a0000001-0000-0000-0000-000000000007', 'chris.bosh@gatech.edu', 'Chris Bosh', 690, false, now() - interval '16 days'),
    ('a0000001-0000-0000-0000-000000000008', 'tashard.choice@gatech.edu', 'Tashard Choice', 605, false, now() - interval '14 days'),
    ('a0000001-0000-0000-0000-000000000009', 'derrick.morgan@gatech.edu', 'Derrick Morgan', 540, false, now() - interval '12 days'),
    ('a0000001-0000-0000-0000-000000000010', 'morgan.burnett@gatech.edu', 'Morgan Burnett', 475, false, now() - interval '10 days'),
    ('a0000001-0000-0000-0000-000000000011', 'dontae.harris@gatech.edu', 'Dontae Harris', 410, false, now() - interval '8 days'),
    ('a0000001-0000-0000-0000-000000000012', 'shaq.mason@gatech.edu', 'Shaq Mason', 350, false, now() - interval '6 days'),
    ('a0000001-0000-0000-0000-000000000013', 'adam.gotsis@gatech.edu', 'Adam Gotsis', 290, false, now() - interval '5 days'),
    ('a0000001-0000-0000-0000-000000000014', 'marco.coleman@gatech.edu', 'Marco Coleman', 225, false, now() - interval '4 days'),
    ('a0000001-0000-0000-0000-000000000015', 'pat.swilling@gatech.edu', 'Pat Swilling', 160, false, now() - interval '3 days')
ON CONFLICT (id) DO NOTHING;


-- ============================================
-- REWARDS
-- ============================================

INSERT INTO rewards (id, name, description, point_cost, quantity_available, category, created_at) VALUES
    -- Merchandise
    (gen_random_uuid(), 'GT Gameday T-Shirt', 'Official Georgia Tech Athletics white and gold gameday tee', 200, 50, 'Merchandise', now()),
    (gen_random_uuid(), 'Ramblin Wreck Hat', 'Navy and gold fitted cap with the Ramblin Wreck logo', 150, 75, 'Merchandise', now()),
    (gen_random_uuid(), 'Buzz Plush Toy', 'Adorable 12-inch Buzz the Yellow Jacket stuffed animal', 300, 25, 'Merchandise', now()),
    (gen_random_uuid(), 'GT Rally Towel', 'Gold rally towel — perfect for Bobby Dodd Stadium', 75, 200, 'Merchandise', now()),
    (gen_random_uuid(), 'Tech Tower Hoodie', 'Premium navy hoodie with the iconic Tech Tower silhouette', 500, 30, 'Merchandise', now()),

    -- Tickets
    (gen_random_uuid(), 'Football Student Guest Pass', 'One guest pass for any home football game at Bobby Dodd', 400, 20, 'Tickets', now()),
    (gen_random_uuid(), 'Basketball Courtside Upgrade', 'Upgrade to courtside seats at McCamish Pavilion', 750, 5, 'Tickets', now()),
    (gen_random_uuid(), 'Baseball Doubleheader Tix', 'Two tickets to a Yellow Jackets baseball doubleheader at Russ Chandler', 250, 15, 'Tickets', now()),

    -- Experiences
    (gen_random_uuid(), 'Meet Buzz Pregame', 'Exclusive pregame meet & photo with Buzz on the field', 600, 10, 'Experiences', now()),
    (gen_random_uuid(), 'Locker Room Tour', 'Behind-the-scenes tour of the football locker room and facilities', 800, 8, 'Experiences', now()),
    (gen_random_uuid(), 'Press Box Experience', 'Watch a home game from the Bobby Dodd press box with snacks', 1000, 3, 'Experiences', now()),

    -- Food & Drink
    (gen_random_uuid(), 'Junior''s Grill Gift Card', '$10 gift card to the legendary Junior''s Grill on campus', 100, 40, 'Food & Drink', now()),
    (gen_random_uuid(), 'Gameday Concession Voucher', '$15 concession voucher for any home athletic event', 125, 60, 'Food & Drink', now()),
    (gen_random_uuid(), 'Waffle House Breakfast Pack', 'Waffle House gift card — a true Georgia tradition', 150, 30, 'Food & Drink', now()),

    -- Digital
    (gen_random_uuid(), 'Custom Buzz Wallpaper Pack', 'Exclusive phone & desktop wallpapers featuring Buzz', 50, -1, 'Digital', now()),
    (gen_random_uuid(), 'GT Trivia VIP Badge', 'Gold VIP badge displayed next to your name on the leaderboard', 350, -1, 'Digital', now()),
    (gen_random_uuid(), '2x Points Booster (1 Day)', 'Double your trivia points for 24 hours', 250, -1, 'Digital', now())
ON CONFLICT (id) DO NOTHING;


-- ============================================
-- TRIVIA QUESTIONS (trivia_videos table)
-- These are pre-loaded and inactive, ready for admin to activate
-- ============================================

INSERT INTO trivia_videos (id, title, description, video_url, scheduled_time, is_active, question_text, options, correct_answer_index, point_value, time_limit_seconds, uploaded_by, created_at) VALUES
    (gen_random_uuid(),
     'GT Football History',
     'Test your knowledge of Yellow Jackets football!',
     'https://placeholder.com',
     now(),
     false,
     'In what year did Georgia Tech win its most recent consensus national championship in football?',
     '["1952", "1990", "1985", "2001"]',
     1,  -- 1990
     15,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'Bobby Dodd Stadium',
     'How well do you know our home field?',
     'https://placeholder.com',
     now(),
     false,
     'What is the seating capacity of Bobby Dodd Stadium?',
     '["45,000", "55,000", "52,572", "60,000"]',
     2,  -- 52,572
     15,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'GT Basketball Legends',
     'Yellow Jackets hoops trivia',
     'https://placeholder.com',
     now(),
     false,
     'Which Georgia Tech basketball player was drafted #1 overall in the 2003 NBA Draft?',
     '["Jarrett Jack", "Chris Bosh", "Stephon Marbury", "Kenny Anderson"]',
     1,  -- Chris Bosh
     20,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'Megatron Trivia',
     'All about Calvin Johnson',
     'https://placeholder.com',
     now(),
     false,
     'What jersey number did Calvin Johnson wear at Georgia Tech?',
     '["81", "21", "7", "1"]',
     1,  -- #21
     10,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'GT Traditions',
     'How well do you know Yellow Jacket traditions?',
     'https://placeholder.com',
     now(),
     false,
     'What is the name of the antique car that leads the team onto the field before every home game?',
     '["The Buzz Mobile", "The Gold Rush", "The Ramblin'' Wreck", "The Tech Express"]',
     2,  -- The Ramblin' Wreck
     10,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'Fight Song',
     'Do you know the words?',
     'https://placeholder.com',
     now(),
     false,
     'What are the opening words to the Ramblin'' Wreck fight song?',
     '["I''m a Ramblin'' Wreck from Georgia Tech", "Hail to Georgia Tech", "Go Jackets, Go Jackets", "We are the Yellow Jackets"]',
     0,  -- I'm a Ramblin' Wreck from Georgia Tech
     10,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'GT Campus',
     'Campus knowledge check',
     'https://placeholder.com',
     now(),
     false,
     'How many letters are illuminated on top of the Tech Tower?',
     '["3", "4", "5", "6"]',
     1,  -- 4 (T-E-C-H)
     10,
     30,
     'admin',
     now()
    ),

    (gen_random_uuid(),
     'Conference Trivia',
     'Yellow Jackets in the ACC',
     'https://placeholder.com',
     now(),
     false,
     'In what year did Georgia Tech join the ACC?',
     '["1978", "1983", "1979", "1990"]',
     2,  -- 1979
     15,
     30,
     'admin',
     now()
    )
ON CONFLICT (id) DO NOTHING;
