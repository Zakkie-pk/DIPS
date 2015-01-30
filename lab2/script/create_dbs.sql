--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: before_insert_into_auth_codes(); Type: FUNCTION; Schema: public; Owner: spectre
--

CREATE FUNCTION before_insert_into_auth_codes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (TG_OP != 'INSERT') THEN
		RAISE EXCEPTION 'This trigger should be called only for inserts';
	END IF;

	IF EXISTS (SELECT 1 FROM auth_codes
		   WHERE user_id=NEW.user_id AND client_id=NEW.client_id) THEN
		-- update record instead of inserting
		UPDATE auth_codes
		SET
			code=NEW.code,
			expiration_date=NEW.expiration_date,
			redirect_uri=NEW.redirect_uri
		WHERE user_id=NEW.user_id AND client_id=NEW.client_id;

		RETURN NULL;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.before_insert_into_auth_codes() OWNER TO spectre;

--
-- Name: before_insert_into_tokens(); Type: FUNCTION; Schema: public; Owner: spectre
--

CREATE FUNCTION before_insert_into_tokens() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	IF (TG_OP != 'INSERT') THEN
		RAISE EXCEPTION 'This trigger should be called only for inserts';
	END IF;

	IF EXISTS (SELECT 1 FROM tokens
		   WHERE user_id=NEW.user_id AND client_id=NEW.client_id) THEN
		-- update record instead of inserting
		UPDATE tokens
		SET
			access_token=NEW.access_token,
			refresh_token=NEW.refresh_token,
			expiration_date=NEW.expiration_date
		WHERE user_id=NEW.user_id AND client_id=NEW.client_id;

		RETURN NULL;
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.before_insert_into_tokens() OWNER TO spectre;

--
-- Name: delete_expired_auth_codes(); Type: FUNCTION; Schema: public; Owner: spectre
--

CREATE FUNCTION delete_expired_auth_codes() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	DELETE FROM auth_codes
	WHERE expiration_date < now();
	RETURN NULL;
END;
$$;


ALTER FUNCTION public.delete_expired_auth_codes() OWNER TO spectre;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: applications; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE applications (
    user_id text NOT NULL,
    client_id integer NOT NULL,
    client_secret text NOT NULL
);


ALTER TABLE public.applications OWNER TO spectre;

--
-- Name: auth_codes; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE auth_codes (
    user_id text NOT NULL,
    client_id integer NOT NULL,
    code text NOT NULL,
    expiration_date timestamp without time zone NOT NULL,
    redirect_uri text
);


ALTER TABLE public.auth_codes OWNER TO spectre;

--
-- Name: firms; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE firms (
    id integer NOT NULL,
    name text,
    description text
);


ALTER TABLE public.firms OWNER TO spectre;

--
-- Name: firms_id_seq; Type: SEQUENCE; Schema: public; Owner: spectre
--

CREATE SEQUENCE firms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.firms_id_seq OWNER TO spectre;

--
-- Name: firms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spectre
--

ALTER SEQUENCE firms_id_seq OWNED BY firms.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE tokens (
    user_id text NOT NULL,
    client_id integer NOT NULL,
    access_token text NOT NULL,
    refresh_token text NOT NULL,
    expiration_date timestamp without time zone NOT NULL
);


ALTER TABLE public.tokens OWNER TO spectre;

--
-- Name: users; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE users (
    login text NOT NULL,
    name text,
    phone text,
    email text,
    pass text NOT NULL
);


ALTER TABLE public.users OWNER TO spectre;

--
-- Name: vacancies; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE vacancies (
    firm_id integer NOT NULL,
    work_id integer NOT NULL
);


ALTER TABLE public.vacancies OWNER TO spectre;

--
-- Name: works; Type: TABLE; Schema: public; Owner: spectre; Tablespace: 
--

CREATE TABLE works (
    id integer NOT NULL,
    name text,
    salary money,
    requirements text
);


ALTER TABLE public.works OWNER TO spectre;

--
-- Name: works_id_seq; Type: SEQUENCE; Schema: public; Owner: spectre
--

CREATE SEQUENCE works_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.works_id_seq OWNER TO spectre;

--
-- Name: works_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: spectre
--

ALTER SEQUENCE works_id_seq OWNED BY works.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY firms ALTER COLUMN id SET DEFAULT nextval('firms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY works ALTER COLUMN id SET DEFAULT nextval('works_id_seq'::regclass);


--
-- Data for Name: applications; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY applications (user_id, client_id, client_secret) FROM stdin;
spectre	1	JInBh4xuO2czsiR
spectre	2	dT2/ym8RR4USgY4
\.


--
-- Data for Name: auth_codes; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY auth_codes (user_id, client_id, code, expiration_date, redirect_uri) FROM stdin;
\.


--
-- Data for Name: firms; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY firms (id, name, description) FROM stdin;
2	Yandex	Yandex description
3	HH	Head Hunter
4	Samsung	Samsung Research Center
5	Intel	Intel Corporation
1	Mail.ru	компания Mail.ru Group
\.


--
-- Name: firms_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spectre
--

SELECT pg_catalog.setval('firms_id_seq', 5, true);


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY tokens (user_id, client_id, access_token, refresh_token, expiration_date) FROM stdin;
spectre	1	961559944359	729b42212a0b	2014-11-13 18:31:30.154727
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY users (login, name, phone, email, pass) FROM stdin;
spectre	Slava	some_phone	spectre@mail.ru	123
\.


--
-- Data for Name: vacancies; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY vacancies (firm_id, work_id) FROM stdin;
2	6
3	7
4	8
5	9
1	1
1	2
1	3
1	4
1	5
4	10
4	11
5	12
5	13
5	14
3	15
3	16
3	17
2	21
2	22
2	18
2	19
1	20
\.


--
-- Data for Name: works; Type: TABLE DATA; Schema: public; Owner: spectre
--

COPY works (id, name, salary, requirements) FROM stdin;
1	programmer c	$50,000.00	c, gcc, git, linux
2	programmer c++	$60,000.00	c++, stl, gcc, git, linux
3	programmer java	$55,000.00	java, git, svn, android
4	programmer perl	$70,000.00	perl, git, linux, mojolicious, sql
5	programmer python	$60,000.00	python, linux, jango, tornado, flask
6	manager	$20,000.00	english
7	manager	$20,000.00	english
8	manager	$20,000.00	english
9	manager	$20,000.00	english
10	programmer c	$50,000.00	c, gcc, git, linux
11	programmer c	$50,000.00	c, gcc, git, linux
12	programmer c++	$60,000.00	c++, stl, gcc, git, linux
13	programmer c++	$60,000.00	c++, stl, gcc, git, linux
14	programmer c++	$60,000.00	c++, stl, gcc, git, linux
15	programmer java	$55,000.00	java, git, svn, android
16	programmer java	$55,000.00	java, git, svn, android
17	programmer java	$55,000.00	java, git, svn, android
18	programmer perl	$70,000.00	perl, git, linux, mojolicious, sql
19	programmer perl	$70,000.00	perl, git, linux, mojolicious, sql
20	programmer perl	$70,000.00	perl, git, linux, mojolicious, sql
21	programmer python	$60,000.00	python, linux, jango, tornado, flask
22	programmer python	$60,000.00	python, linux, jango, tornado, flask
\.


--
-- Name: works_id_seq; Type: SEQUENCE SET; Schema: public; Owner: spectre
--

SELECT pg_catalog.setval('works_id_seq', 22, true);


--
-- Name: applications_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_pkey PRIMARY KEY (client_id);


--
-- Name: auth_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY auth_codes
    ADD CONSTRAINT auth_codes_pkey PRIMARY KEY (user_id, client_id);


--
-- Name: firms_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY firms
    ADD CONSTRAINT firms_pkey PRIMARY KEY (id);


--
-- Name: tokens_access_token_key; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_access_token_key UNIQUE (access_token);


--
-- Name: tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (user_id, client_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (login);


--
-- Name: vacancies_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY vacancies
    ADD CONSTRAINT vacancies_pkey PRIMARY KEY (firm_id, work_id);


--
-- Name: vacancies_work_id_key; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY vacancies
    ADD CONSTRAINT vacancies_work_id_key UNIQUE (work_id);


--
-- Name: works_pkey; Type: CONSTRAINT; Schema: public; Owner: spectre; Tablespace: 
--

ALTER TABLE ONLY works
    ADD CONSTRAINT works_pkey PRIMARY KEY (id);


--
-- Name: after_ins_udp_auth_codes; Type: TRIGGER; Schema: public; Owner: spectre
--

CREATE TRIGGER after_ins_udp_auth_codes AFTER INSERT OR UPDATE ON auth_codes FOR EACH STATEMENT EXECUTE PROCEDURE delete_expired_auth_codes();


--
-- Name: auth_codes_before_insert_trigger; Type: TRIGGER; Schema: public; Owner: spectre
--

CREATE TRIGGER auth_codes_before_insert_trigger BEFORE INSERT ON auth_codes FOR EACH ROW EXECUTE PROCEDURE before_insert_into_auth_codes();


--
-- Name: tokens_before_insert_trigger; Type: TRIGGER; Schema: public; Owner: spectre
--

CREATE TRIGGER tokens_before_insert_trigger BEFORE INSERT ON tokens FOR EACH ROW EXECUTE PROCEDURE before_insert_into_tokens();


--
-- Name: applications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY applications
    ADD CONSTRAINT applications_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(login);


--
-- Name: auth_codes_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY auth_codes
    ADD CONSTRAINT auth_codes_client_id_fkey FOREIGN KEY (client_id) REFERENCES applications(client_id);


--
-- Name: auth_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY auth_codes
    ADD CONSTRAINT auth_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(login);


--
-- Name: tokens_client_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_client_id_fkey FOREIGN KEY (client_id) REFERENCES applications(client_id);


--
-- Name: tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY tokens
    ADD CONSTRAINT tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(login);


--
-- Name: vacancies_firm_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY vacancies
    ADD CONSTRAINT vacancies_firm_id_fkey FOREIGN KEY (firm_id) REFERENCES firms(id);


--
-- Name: vacancies_work_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: spectre
--

ALTER TABLE ONLY vacancies
    ADD CONSTRAINT vacancies_work_id_fkey FOREIGN KEY (work_id) REFERENCES works(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

