-- Create coupons table
CREATE TABLE IF NOT EXISTS public.coupons (
    code text NOT NULL PRIMARY KEY,
    reward_type text NOT NULL CHECK (reward_type IN ('stars', 'theme')),
    reward_value text NOT NULL, -- Can be integer (as string) for stars, or ID for others
    expiration_date timestamp with time zone NOT NULL,
    max_uses integer NOT NULL DEFAULT 1,
    current_uses integer NOT NULL DEFAULT 0,
    created_at timestamp with time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

-- Create policy to allow read access for authenticated and anon users
CREATE POLICY "Allow read access for all users" ON public.coupons
    FOR SELECT
    TO authenticated, anon
    USING (true);

-- Create policy to allow update access for authenticated and anon users (to increment usage)
CREATE POLICY "Allow update access for all users" ON public.coupons
    FOR UPDATE
    TO authenticated, anon
    USING (true)
    WITH CHECK (true);

-- Insert some sample coupons
INSERT INTO public.coupons (code, reward_type, reward_value, expiration_date, max_uses)
VALUES 
    ('WELCOME2025', 'stars', '100', '2025-12-31 23:59:59+00', 1000),
    ('STARTER2025', 'stars', '50', '2025-12-31 23:59:59+00', 1000),
    ('BONUS500', 'stars', '500', '2025-12-31 23:59:59+00', 100),
    ('THEME_GIFT', 'theme', 'christmas', '2025-12-31 23:59:59+00', 50),
    ('THEME_OLED', 'theme', 'oled', '2025-12-31 23:59:59+00', 50),
    ('THEME_GREEN', 'theme', 'green', '2025-12-31 23:59:59+00', 50)
ON CONFLICT (code) DO NOTHING;
