WESTERN KICKS TECH HUB — CONNECTED BACKEND + ADMIN DASHBOARD

WHAT IS INCLUDED
- Existing multi-page marketplace: Home, Shop, Repairs, About, Contact.
- Supabase database for shared products, repair requests, contact enquiries and order enquiries.
- Supabase Storage for uploaded product photographs.
- Secure admin sign-in using Supabase Auth.
- Admin product create, edit, publish/hide and delete controls.
- Admin lists for recent customer repair, contact and order enquiries.
- Public catalogue reads live products from the shared database.

IMPORTANT: This is a ready-to-configure integration package, not a live hosted backend yet. You must create your own Supabase project and add its public project URL and anon key. Never put a Supabase service_role key in frontend files.

SETUP (ABOUT 15–25 MINUTES)
1. Create a free Supabase project at https://supabase.com/ and wait for it to finish provisioning.
2. Open SQL Editor in Supabase. Choose New query, paste all of backend/schema.sql, and click Run.
3. In Supabase, open Project Settings > API (or API Keys). Copy the Project URL and the publishable/anon public key.
4. Open supabase-config.js. Replace YOUR_SUPABASE_PROJECT_URL and YOUR_SUPABASE_ANON_KEY with those two values. Do not use the service_role/secret key. Replace the sample WhatsApp number with your real number in international digits-only format (Uganda example starts 2567...).
5. In Supabase Authentication > Providers, ensure Email is enabled. In Authentication > Users, add/invite an admin user with an email and a strong password. Disable public sign-ups in Authentication settings if enabled.
6. Copy the new user's UUID from Authentication > Users. Open SQL Editor and run: insert into public.admin_users (user_id) values ('PASTE-USER-UUID-HERE'); Replace the placeholder with the UUID. This grants admin access.
7. Deploy the entire extracted folder to a static host such as Netlify. Keep all HTML, CSS, JS and backend folder structure together.
8. Open your deployed /admin.html, sign in with the admin email/password, and add your products. They will appear on the public Shop page for every visitor.

LOCAL TEST
- Do not just double-click the HTML files if the browser blocks module/CDN/network behaviour. Run a local static server from this folder, e.g. Python: python -m http.server 8000, then visit http://localhost:8000.
- Or deploy the folder to Netlify and test the deployed site.

SECURITY NOTES
- Only the public anon/publishable key belongs in supabase-config.js. Row Level Security (RLS) in schema.sql restricts product writes, admin data and image uploads to user IDs listed in admin_users.
- Keep the admin password private. Do not add an admin user ID you do not control.
- Customer-submitted enquiries are public inserts and admin-only reads. Add spam protection/rate limiting before heavy public promotion.
- Order enquiries are not payment transactions. WhatsApp is used to confirm the order; no card or Mobile Money payment is collected by this version.
- Product photos in the starter catalogue are illustrative Unsplash images. Replace them with photos of actual stock and confirm real prices/availability before accepting orders.
- Back up your Supabase project and review its free-plan limits and data retention before relying on it for business-critical records.

FILES
- index.html, shop.html, repairs.html, about.html, contact.html, admin.html
- app.js, styles.css, supabase-config.js
- backend/schema.sql
Tesocollege#24#24