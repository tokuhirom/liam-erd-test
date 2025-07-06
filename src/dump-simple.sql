--
-- PostgreSQL database dump
--

-- Dumped from database version 15.13
-- Dumped by pg_dump version 15.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: bar; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bar (
    bar_id integer NOT NULL,
    foo_id integer NOT NULL
);


ALTER TABLE public.bar OWNER TO postgres;

--
-- Name: foo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.foo (
    foo_id integer NOT NULL
);


ALTER TABLE public.foo OWNER TO postgres;

--
-- Name: bar bar_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bar
    ADD CONSTRAINT bar_pkey PRIMARY KEY (bar_id);


--
-- Name: foo foo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.foo
    ADD CONSTRAINT foo_pkey PRIMARY KEY (foo_id);


--
-- Name: bar fk_bar_foo; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bar
    ADD CONSTRAINT fk_bar_foo FOREIGN KEY (foo_id) REFERENCES public.foo(foo_id);


--
-- PostgreSQL database dump complete
--

