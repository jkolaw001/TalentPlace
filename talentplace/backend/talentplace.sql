drop table if exists applications;
drop table if exists users;
drop table if exists profiles;
drop table if exists jobs;
drop table if exists contracts;
drop table if exists payments;
drop table if exists messages;
drop table if exists reviews;
drop table if exists embeddings;

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";


CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT CHECK (role IN ('client','freelancer','admin')) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    display_name TEXT,
    bio TEXT,
    hourly_rate NUMERIC(10,2),
    location TEXT,
    skills TEXT[],
    portfolio JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE jobs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    budget NUMERIC(10,2),
    status TEXT CHECK (status IN ('open','in_progress','completed','cancelled')) DEFAULT 'open',
    tags TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE applications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    freelancer_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    cover_letter TEXT,
    proposed_rate NUMERIC(10,2),
    status TEXT CHECK (status IN ('pending','accepted','rejected')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(job_id, freelancer_id)
);


CREATE TABLE contracts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_id UUID NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
    client_id UUID NOT NULL REFERENCES users(id),
    freelancer_id UUID NOT NULL REFERENCES users(id),
    agreed_rate NUMERIC(10,2),
    start_date DATE,
    end_date DATE,
    status TEXT CHECK (status IN ('active','completed','disputed')) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    amount NUMERIC(10,2),
    status TEXT CHECK (status IN ('pending','completed','failed')) DEFAULT 'pending',
    provider TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id UUID NOT NULL REFERENCES users(id),
    receiver_id UUID NOT NULL REFERENCES users(id),
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id UUID NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES users(id),
    reviewee_id UUID NOT NULL REFERENCES users(id),
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(contract_id, reviewer_id)
);


CREATE TABLE embeddings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_type TEXT CHECK (entity_type IN ('job','profile')) NOT NULL,
    entity_id UUID NOT NULL,
    vector VECTOR(1536),
    created_at TIMESTAMP DEFAULT NOW()
);


CREATE INDEX idx_profiles_skills ON profiles USING gin (skills);
CREATE INDEX idx_jobs_tags ON jobs USING gin (tags);
CREATE INDEX idx_applications_status ON applications(status);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_embeddings_entity ON embeddings(entity_type, entity_id);
CREATE INDEX idx_embeddings_vector ON embeddings USING ivfflat (vector vector_l2_ops) WITH (lists = 100);
