
INSERT INTO users (id, email, password_hash, role)
VALUES
  (gen_random_uuid(), 'alice@freelance.com', crypt('password123', gen_salt('bf')), 'freelancer'),
  (gen_random_uuid(), 'bob@client.com', crypt('password123', gen_salt('bf')), 'client'),
  (gen_random_uuid(), 'carol@freelance.com', crypt('password123', gen_salt('bf')), 'freelancer');


INSERT INTO profiles (id, user_id, display_name, bio, hourly_rate, location, skills, portfolio)
VALUES
  (gen_random_uuid(), (SELECT id FROM users WHERE email='alice@freelance.com'),
   'Alice Johnson', 'Full-stack developer with React & FastAPI experience.',
   50.00, 'Remote - US', ARRAY['Python','React','FastAPI','PostgreSQL'],
   '[{"name":"Portfolio Site","url":"https://alice.dev"}]'),

  (gen_random_uuid(), (SELECT id FROM users WHERE email='carol@freelance.com'),
   'Carol Lee', 'UX/UI designer for SaaS platforms.',
   40.00, 'Remote - Canada', ARRAY['Figma','UX Research','Prototyping'],
   '[{"name":"Design Samples","url":"https://carol.design"}]');


INSERT INTO jobs (id, client_id, title, description, budget, status, tags)
VALUES
  (gen_random_uuid(), (SELECT id FROM users WHERE email='bob@client.com'),
   'Build AI Marketplace', 'Looking for full-stack developer to build MVP with React + FastAPI.',
   5000.00, 'open', ARRAY['React','FastAPI','AI']);


INSERT INTO applications (id, job_id, freelancer_id, cover_letter, proposed_rate)
VALUES
  (gen_random_uuid(),
   (SELECT id FROM jobs LIMIT 1),
   (SELECT id FROM users WHERE email='alice@freelance.com'),
   'Hi Bob, I have built full-stack apps with React and FastAPI. Excited to help!',
   50.00),

  (gen_random_uuid(),
   (SELECT id FROM jobs LIMIT 1),
   (SELECT id FROM users WHERE email='carol@freelance.com'),
   'Hi, I can help design the UI/UX for your AI Marketplace MVP.',
   45.00);


INSERT INTO contracts (id, job_id, client_id, freelancer_id, agreed_rate, start_date, end_date, status)
VALUES
  (gen_random_uuid(),
   (SELECT id FROM jobs LIMIT 1),
   (SELECT id FROM users WHERE email='bob@client.com'),
   (SELECT id FROM users WHERE email='alice@freelance.com'),
   50.00, CURRENT_DATE, CURRENT_DATE + interval '30 days', 'active');


INSERT INTO payments (id, contract_id, amount, status, provider)
VALUES
  (gen_random_uuid(),
   (SELECT id FROM contracts LIMIT 1),
   2000.00, 'completed', 'stripe');


INSERT INTO messages (id, sender_id, receiver_id, content)
VALUES
  (gen_random_uuid(),
   (SELECT id FROM users WHERE email='bob@client.com'),
   (SELECT id FROM users WHERE email='alice@freelance.com'),
   'Hi Alice, excited to start working on the MVP!');


INSERT INTO reviews (id, contract_id, reviewer_id, reviewee_id, rating, comment)
VALUES
  (gen_random_uuid(),
   (SELECT id FROM contracts LIMIT 1),
   (SELECT id FROM users WHERE email='bob@client.com'),
   (SELECT id FROM users WHERE email='alice@freelance.com'),
   5, 'Alice delivered the MVP ahead of schedule!');


INSERT INTO embeddings (id, entity_type, entity_id, vector)
VALUES
  (gen_random_uuid(), 'profile', (SELECT id FROM profiles WHERE display_name='Alice Johnson'), array_fill(0.01::float8, ARRAY[1536])),
  (gen_random_uuid(), 'profile', (SELECT id FROM profiles WHERE display_name='Carol Lee'), array_fill(0.02::float8, ARRAY[1536])),
  (gen_random_uuid(), 'job', (SELECT id FROM jobs LIMIT 1), array_fill(0.03::float8, ARRAY[1536]));
