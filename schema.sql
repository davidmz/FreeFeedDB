--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.0
-- Dumped by pg_dump version 9.5.0

-- Started on 2016-01-27 12:06:48

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2574 (class 1262 OID 8590725)
-- Dependencies: 2573
-- Name: frf1; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE frf1 IS 'Тестовая база для FreeFeed-а';


--
-- TOC entry 200 (class 3079 OID 12671)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2577 (class 0 OID 0)
-- Dependencies: 200
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 201 (class 1255 OID 8592425)
-- Name: feed_posts_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION feed_posts_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Обновление posts.feed_ids при вставке/удалении в таблице feed_posts.
begin
	if TG_OP = 'INSERT' then
		update posts set feed_ids = feed_ids + NEW.feed_id where id = NEW.post_id;
	end if;

	if TG_OP = 'DELETE' then
		update posts set feed_ids = feed_ids - OLD.feed_id where id = OLD.post_id;
	end if;

	return null;
end;
$$;


--
-- TOC entry 2578 (class 0 OID 0)
-- Dependencies: 201
-- Name: FUNCTION feed_posts_changes(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION feed_posts_changes() IS 'Обновление posts.feed_ids при вставке/удалении в таблице feed_posts.';


--
-- TOC entry 202 (class 1255 OID 8592397)
-- Name: feed_readers_changes(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION feed_readers_changes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- Обновление users.private_feed_ids при вставке/удалении в таблице feed_readers.
begin
	if TG_OP = 'INSERT' then
		update users set private_feed_ids = private_feed_ids + NEW.feed_id where id = NEW.user_id;
	end if;

	if TG_OP = 'DELETE' then
		update users set private_feed_ids = private_feed_ids - OLD.feed_id where id = OLD.user_id;
	end if;

	return null;
end;
$$;


--
-- TOC entry 2579 (class 0 OID 0)
-- Dependencies: 202
-- Name: FUNCTION feed_readers_changes(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION feed_readers_changes() IS 'Обновление users.private_feed_ids при вставке/удалении в таблице feed_readers.';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 187 (class 1259 OID 8590953)
-- Name: aggregates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE aggregates (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    is_primary boolean DEFAULT true NOT NULL,
    title text DEFAULT ''::text NOT NULL,
    feed_ids integer[] DEFAULT ARRAY[]::integer[] NOT NULL
);


--
-- TOC entry 2580 (class 0 OID 0)
-- Dependencies: 187
-- Name: TABLE aggregates; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE aggregates IS 'Агрегаторы фидов (френдленты). У одного пользователя их может быть несколько, но только одна первичная.';


--
-- TOC entry 2581 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN aggregates.is_primary; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN aggregates.is_primary IS 'Первичная френдлента, есть у пользователя по умолчанию.';


--
-- TOC entry 2582 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN aggregates.title; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN aggregates.title IS 'Название для удобства пользователя.';


--
-- TOC entry 2583 (class 0 OID 0)
-- Dependencies: 187
-- Name: COLUMN aggregates.feed_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN aggregates.feed_ids IS 'Фиды, на которые подписан агрегатор.';


--
-- TOC entry 186 (class 1259 OID 8590951)
-- Name: aggregates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE aggregates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2584 (class 0 OID 0)
-- Dependencies: 186
-- Name: aggregates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE aggregates_id_seq OWNED BY aggregates.id;


--
-- TOC entry 192 (class 1259 OID 8591047)
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    author_id integer NOT NULL,
    body text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 191 (class 1259 OID 8591045)
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE comments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2585 (class 0 OID 0)
-- Dependencies: 191
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE comments_id_seq OWNED BY comments.id;


--
-- TOC entry 199 (class 1259 OID 8592402)
-- Name: feed_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE feed_posts (
    post_id integer NOT NULL,
    feed_id integer NOT NULL
);


--
-- TOC entry 2586 (class 0 OID 0)
-- Dependencies: 199
-- Name: TABLE feed_posts; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE feed_posts IS 'Посты в фидах. Эта таблица через триггеры управляет полем posts.feed_ids.';


--
-- TOC entry 189 (class 1259 OID 8591003)
-- Name: feed_readers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE feed_readers (
    feed_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- TOC entry 2587 (class 0 OID 0)
-- Dependencies: 189
-- Name: TABLE feed_readers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE feed_readers IS 'Пользователи, которые имеют право чтения приватных фидов. Эта таблица через триггеры управляет полем users.private_feed_ids.';


--
-- TOC entry 190 (class 1259 OID 8591027)
-- Name: feed_writers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE feed_writers (
    feed_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- TOC entry 2588 (class 0 OID 0)
-- Dependencies: 190
-- Name: TABLE feed_writers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE feed_writers IS 'Пользователи, которые имеют право записи в фиды. Имеет смысл только для фидов групп и директов.';


--
-- TOC entry 185 (class 1259 OID 8590934)
-- Name: feeds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE feeds (
    id integer NOT NULL,
    uid uuid NOT NULL,
    subtype integer NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    owner_id integer,
    type integer NOT NULL
);


--
-- TOC entry 2589 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN feeds.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN feeds.uid IS 'Для совместимости с FreeFeed-ом';


--
-- TOC entry 2590 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN feeds.subtype; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN feeds.subtype IS 'Подтип фида: 1 — фид юзера / группы, 2 — директ-фид, …';


--
-- TOC entry 2591 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN feeds.is_public; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN feeds.is_public IS 'Имеет смысл только для базовых фидов.';


--
-- TOC entry 2592 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN feeds.owner_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN feeds.owner_id IS 'Владелец фида (юзер/группа), null для фильтров.';


--
-- TOC entry 2593 (class 0 OID 0)
-- Dependencies: 185
-- Name: COLUMN feeds.type; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN feeds.type IS 'Тип фида: 1 — базовый, 2 — фильтр.';


--
-- TOC entry 184 (class 1259 OID 8590932)
-- Name: feeds_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE feeds_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2594 (class 0 OID 0)
-- Dependencies: 184
-- Name: feeds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE feeds_id_seq OWNED BY feeds.id;


--
-- TOC entry 198 (class 1259 OID 8591828)
-- Name: files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE files (
    id integer NOT NULL,
    uid uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    file_hash bytea NOT NULL,
    size integer NOT NULL,
    mime_type text NOT NULL,
    media text NOT NULL,
    has_thumbnail boolean NOT NULL,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL
);


--
-- TOC entry 2595 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN files.file_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN files.file_hash IS 'Хэш-сумма файла, для дедубликации.';


--
-- TOC entry 2596 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN files.media; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN files.media IS 'image, audio, other';


--
-- TOC entry 2597 (class 0 OID 0)
-- Dependencies: 198
-- Name: COLUMN files.meta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN files.meta IS 'Дополнительные параметры, в зависимости от формата: title, artist, width, height, …';


--
-- TOC entry 197 (class 1259 OID 8591826)
-- Name: files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE files_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2598 (class 0 OID 0)
-- Dependencies: 197
-- Name: files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE files_id_seq OWNED BY files.id;


--
-- TOC entry 194 (class 1259 OID 8591071)
-- Name: likes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE likes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 193 (class 1259 OID 8591069)
-- Name: likes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE likes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2599 (class 0 OID 0)
-- Dependencies: 193
-- Name: likes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE likes_id_seq OWNED BY likes.id;


--
-- TOC entry 188 (class 1259 OID 8590980)
-- Name: local_bumps; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE local_bumps (
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    bumped_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 2600 (class 0 OID 0)
-- Dependencies: 188
-- Name: TABLE local_bumps; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE local_bumps IS 'Локальные бампы постов.';


--
-- TOC entry 196 (class 1259 OID 8591138)
-- Name: post_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE post_attachments (
    post_id integer NOT NULL,
    file_id integer NOT NULL,
    file_name text NOT NULL,
    ord integer NOT NULL
);


--
-- TOC entry 195 (class 1259 OID 8591136)
-- Name: post_attachments_ord_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE post_attachments_ord_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2601 (class 0 OID 0)
-- Dependencies: 195
-- Name: post_attachments_ord_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE post_attachments_ord_seq OWNED BY post_attachments.ord;


--
-- TOC entry 183 (class 1259 OID 8590828)
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE posts (
    id integer NOT NULL,
    uid uuid NOT NULL,
    author_id integer NOT NULL,
    body text NOT NULL,
    is_public boolean DEFAULT true NOT NULL,
    is_comments_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    bumped_at timestamp with time zone DEFAULT now() NOT NULL,
    feed_ids integer[] NOT NULL
);


--
-- TOC entry 2602 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN posts.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN posts.uid IS 'Для совместимости с FreeFeed-ом';


--
-- TOC entry 2603 (class 0 OID 0)
-- Dependencies: 183
-- Name: COLUMN posts.feed_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN posts.feed_ids IS 'Фиды, в которые опубликован пост.';


--
-- TOC entry 182 (class 1259 OID 8590826)
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2604 (class 0 OID 0)
-- Dependencies: 182
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- TOC entry 181 (class 1259 OID 8590765)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    uid uuid NOT NULL,
    username text NOT NULL,
    screenname text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    is_group boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    email text,
    pw_hash text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    private_feed_ids integer[] DEFAULT ARRAY[]::integer[] NOT NULL,
    CONSTRAINT users_check CHECK ((is_group = (email IS NULL))),
    CONSTRAINT users_check1 CHECK ((is_group = (pw_hash IS NULL)))
);


--
-- TOC entry 2605 (class 0 OID 0)
-- Dependencies: 181
-- Name: TABLE users; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE users IS 'Пользователи и группы';


--
-- TOC entry 2606 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN users.uid; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.uid IS 'Для совместимости с FreeFeed-ом';


--
-- TOC entry 2607 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN users.is_active; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.is_active IS 'Если значение false, то пользователь удалён.';


--
-- TOC entry 2608 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN users.email; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.email IS 'Null для групп.';


--
-- TOC entry 2609 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN users.pw_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.pw_hash IS 'Хэш пароля, null для групп.';


--
-- TOC entry 2610 (class 0 OID 0)
-- Dependencies: 181
-- Name: COLUMN users.private_feed_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN users.private_feed_ids IS 'Приватные фиды, которые может читать пользователь.';


--
-- TOC entry 180 (class 1259 OID 8590763)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2611 (class 0 OID 0)
-- Dependencies: 180
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- TOC entry 2376 (class 2604 OID 8590956)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY aggregates ALTER COLUMN id SET DEFAULT nextval('aggregates_id_seq'::regclass);


--
-- TOC entry 2381 (class 2604 OID 8591050)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments ALTER COLUMN id SET DEFAULT nextval('comments_id_seq'::regclass);


--
-- TOC entry 2374 (class 2604 OID 8590937)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeds ALTER COLUMN id SET DEFAULT nextval('feeds_id_seq'::regclass);


--
-- TOC entry 2386 (class 2604 OID 8591831)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY files ALTER COLUMN id SET DEFAULT nextval('files_id_seq'::regclass);


--
-- TOC entry 2383 (class 2604 OID 8591074)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes ALTER COLUMN id SET DEFAULT nextval('likes_id_seq'::regclass);


--
-- TOC entry 2385 (class 2604 OID 8591141)
-- Name: ord; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_attachments ALTER COLUMN ord SET DEFAULT nextval('post_attachments_ord_seq'::regclass);


--
-- TOC entry 2369 (class 2604 OID 8590831)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- TOC entry 2361 (class 2604 OID 8590768)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- TOC entry 2412 (class 2606 OID 8590964)
-- Name: aggregates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aggregates
    ADD CONSTRAINT aggregates_pkey PRIMARY KEY (id);


--
-- TOC entry 2429 (class 2606 OID 8591840)
-- Name: attachments_file_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY files
    ADD CONSTRAINT attachments_file_hash_key UNIQUE (file_hash);


--
-- TOC entry 2431 (class 2606 OID 8591838)
-- Name: attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY files
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- TOC entry 2433 (class 2606 OID 8591842)
-- Name: attachments_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY files
    ADD CONSTRAINT attachments_uid_key UNIQUE (uid);


--
-- TOC entry 2421 (class 2606 OID 8591056)
-- Name: comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- TOC entry 2435 (class 2606 OID 8592406)
-- Name: feed_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_posts
    ADD CONSTRAINT feed_posts_pkey PRIMARY KEY (post_id, feed_id);


--
-- TOC entry 2416 (class 2606 OID 8591007)
-- Name: feed_readers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_readers
    ADD CONSTRAINT feed_readers_pkey PRIMARY KEY (feed_id, user_id);


--
-- TOC entry 2418 (class 2606 OID 8591031)
-- Name: feed_writers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_writers
    ADD CONSTRAINT feed_writers_pkey PRIMARY KEY (feed_id, user_id);


--
-- TOC entry 2407 (class 2606 OID 8590940)
-- Name: feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_pkey PRIMARY KEY (id);


--
-- TOC entry 2409 (class 2606 OID 8590942)
-- Name: feeds_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_uid_key UNIQUE (uid);


--
-- TOC entry 2424 (class 2606 OID 8591077)
-- Name: likes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_pkey PRIMARY KEY (id);


--
-- TOC entry 2414 (class 2606 OID 8590985)
-- Name: local_bumps_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY local_bumps
    ADD CONSTRAINT local_bumps_pkey PRIMARY KEY (post_id, user_id);


--
-- TOC entry 2427 (class 2606 OID 8591146)
-- Name: post_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_attachments
    ADD CONSTRAINT post_attachments_pkey PRIMARY KEY (post_id, file_id);


--
-- TOC entry 2403 (class 2606 OID 8590840)
-- Name: posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- TOC entry 2405 (class 2606 OID 8590842)
-- Name: posts_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_uid_key UNIQUE (uid);


--
-- TOC entry 2391 (class 2606 OID 8590780)
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 2394 (class 2606 OID 8590782)
-- Name: users_uid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_uid_key UNIQUE (uid);


--
-- TOC entry 2397 (class 2606 OID 8590784)
-- Name: users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 2410 (class 1259 OID 8590974)
-- Name: aggregates_feed_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX aggregates_feed_ids_idx ON aggregates USING gin (feed_ids);


--
-- TOC entry 2419 (class 1259 OID 8591068)
-- Name: comments_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX comments_created_at_idx ON comments USING btree (created_at);


--
-- TOC entry 2425 (class 1259 OID 8591857)
-- Name: fki_post_attachments_file_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_post_attachments_file_id_fkey ON post_attachments USING btree (file_id);


--
-- TOC entry 2422 (class 1259 OID 8591088)
-- Name: likes_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX likes_created_at_idx ON likes USING btree (created_at);


--
-- TOC entry 2398 (class 1259 OID 8590862)
-- Name: posts_bumped_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_bumped_at_idx ON posts USING btree (bumped_at);


--
-- TOC entry 2399 (class 1259 OID 8590882)
-- Name: posts_created_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_created_at_idx ON posts USING btree (created_at);


--
-- TOC entry 2400 (class 1259 OID 8590849)
-- Name: posts_feed_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_feed_ids_idx ON posts USING gin (feed_ids);


--
-- TOC entry 2401 (class 1259 OID 8590854)
-- Name: posts_is_public_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX posts_is_public_idx ON posts USING btree (is_public);


--
-- TOC entry 2389 (class 1259 OID 8590786)
-- Name: users_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_email_idx ON users USING btree (email);


--
-- TOC entry 2392 (class 1259 OID 8590789)
-- Name: users_private_feed_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_private_feed_ids_idx ON users USING gin (private_feed_ids);


--
-- TOC entry 2395 (class 1259 OID 8590785)
-- Name: users_username_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX users_username_idx ON users USING btree (username);


--
-- TOC entry 2454 (class 2620 OID 8592426)
-- Name: feed_posts_changes_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_posts_changes_trg AFTER INSERT OR DELETE ON feed_posts FOR EACH ROW EXECUTE PROCEDURE feed_posts_changes();


--
-- TOC entry 2453 (class 2620 OID 8592398)
-- Name: feed_readers_changes_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER feed_readers_changes_trg AFTER INSERT OR DELETE ON feed_readers FOR EACH ROW EXECUTE PROCEDURE feed_readers_changes();


--
-- TOC entry 2438 (class 2606 OID 8590965)
-- Name: aggregates_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY aggregates
    ADD CONSTRAINT aggregates_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2446 (class 2606 OID 8591062)
-- Name: comments_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2445 (class 2606 OID 8591057)
-- Name: comments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY comments
    ADD CONSTRAINT comments_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2451 (class 2606 OID 8592407)
-- Name: feed_posts_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_posts
    ADD CONSTRAINT feed_posts_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES feeds(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2452 (class 2606 OID 8592412)
-- Name: feed_posts_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_posts
    ADD CONSTRAINT feed_posts_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2441 (class 2606 OID 8591008)
-- Name: feed_readers_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_readers
    ADD CONSTRAINT feed_readers_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES feeds(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2442 (class 2606 OID 8591013)
-- Name: feed_readers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_readers
    ADD CONSTRAINT feed_readers_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2443 (class 2606 OID 8591032)
-- Name: feed_writers_feed_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_writers
    ADD CONSTRAINT feed_writers_feed_id_fkey FOREIGN KEY (feed_id) REFERENCES feeds(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2444 (class 2606 OID 8591037)
-- Name: feed_writers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feed_writers
    ADD CONSTRAINT feed_writers_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2437 (class 2606 OID 8590943)
-- Name: feeds_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2448 (class 2606 OID 8591083)
-- Name: likes_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2447 (class 2606 OID 8591078)
-- Name: likes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY likes
    ADD CONSTRAINT likes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2440 (class 2606 OID 8590991)
-- Name: local_bumps_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY local_bumps
    ADD CONSTRAINT local_bumps_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2439 (class 2606 OID 8590986)
-- Name: local_bumps_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY local_bumps
    ADD CONSTRAINT local_bumps_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2450 (class 2606 OID 8591852)
-- Name: post_attachments_file_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_attachments
    ADD CONSTRAINT post_attachments_file_id_fkey FOREIGN KEY (file_id) REFERENCES files(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2449 (class 2606 OID 8591152)
-- Name: post_attachments_post_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY post_attachments
    ADD CONSTRAINT post_attachments_post_id_fkey FOREIGN KEY (post_id) REFERENCES posts(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2436 (class 2606 OID 8590843)
-- Name: posts_author_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_author_id_fkey FOREIGN KEY (author_id) REFERENCES users(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2576 (class 0 OID 0)
-- Dependencies: 6
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pgsql;
GRANT ALL ON SCHEMA public TO pgsql;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2016-01-27 12:06:53

--
-- PostgreSQL database dump complete
--

