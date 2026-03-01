-- Migration: Create predictions and prediction_votes tables
-- Run this in Supabase SQL Editor

-- Predictions table
CREATE TABLE IF NOT EXISTS predictions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    point_value INTEGER DEFAULT 10,
    is_active BOOLEAN DEFAULT true,
    is_closed BOOLEAN DEFAULT false,
    correct_answer BOOLEAN,  -- NULL while open; true = YES wins, false = NO wins
    created_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    closed_at TIMESTAMPTZ
);

-- Prediction votes table
CREATE TABLE IF NOT EXISTS prediction_votes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    prediction_id UUID NOT NULL REFERENCES predictions(id) ON DELETE CASCADE,
    vote BOOLEAN NOT NULL,  -- true = YES, false = NO
    points_earned INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, prediction_id)  -- one vote per user per prediction
);

-- Enable RLS
ALTER TABLE predictions ENABLE ROW LEVEL SECURITY;
ALTER TABLE prediction_votes ENABLE ROW LEVEL SECURITY;

-- Predictions policies: everyone can read, admins can insert/update/delete
CREATE POLICY "Anyone can read predictions"
    ON predictions FOR SELECT
    USING (true);

CREATE POLICY "Admins can insert predictions"
    ON predictions FOR INSERT
    WITH CHECK (true);

CREATE POLICY "Admins can update predictions"
    ON predictions FOR UPDATE
    USING (true);

CREATE POLICY "Admins can delete predictions"
    ON predictions FOR DELETE
    USING (true);

-- Prediction votes policies
CREATE POLICY "Users can read own votes"
    ON prediction_votes FOR SELECT
    USING (true);

CREATE POLICY "Users can insert own votes"
    ON prediction_votes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "System can update votes (points payout)"
    ON prediction_votes FOR UPDATE
    USING (true);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_prediction_votes_prediction_id ON prediction_votes(prediction_id);
CREATE INDEX IF NOT EXISTS idx_prediction_votes_user_id ON prediction_votes(user_id);
CREATE INDEX IF NOT EXISTS idx_predictions_is_active ON predictions(is_active);
