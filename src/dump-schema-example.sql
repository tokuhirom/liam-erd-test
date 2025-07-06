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

--
-- Name: hr; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA hr;


ALTER SCHEMA hr OWNER TO postgres;

--
-- Name: SCHEMA hr; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA hr IS '人事管理スキーマ';


--
-- Name: project; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA project;


ALTER SCHEMA project OWNER TO postgres;

--
-- Name: SCHEMA project; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA project IS 'プロジェクト管理スキーマ';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: departments; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.departments (
    department_id integer NOT NULL,
    department_name character varying(100) NOT NULL,
    location character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE hr.departments OWNER TO postgres;

--
-- Name: TABLE departments; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.departments IS '部署マスタ';


--
-- Name: departments_department_id_seq; Type: SEQUENCE; Schema: hr; Owner: postgres
--

CREATE SEQUENCE hr.departments_department_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hr.departments_department_id_seq OWNER TO postgres;

--
-- Name: departments_department_id_seq; Type: SEQUENCE OWNED BY; Schema: hr; Owner: postgres
--

ALTER SEQUENCE hr.departments_department_id_seq OWNED BY hr.departments.department_id;


--
-- Name: employees; Type: TABLE; Schema: hr; Owner: postgres
--

CREATE TABLE hr.employees (
    employee_id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    department_id integer,
    hire_date date NOT NULL,
    salary numeric(10,2),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE hr.employees OWNER TO postgres;

--
-- Name: TABLE employees; Type: COMMENT; Schema: hr; Owner: postgres
--

COMMENT ON TABLE hr.employees IS '従業員マスタ';


--
-- Name: employees_employee_id_seq; Type: SEQUENCE; Schema: hr; Owner: postgres
--

CREATE SEQUENCE hr.employees_employee_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE hr.employees_employee_id_seq OWNER TO postgres;

--
-- Name: employees_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: hr; Owner: postgres
--

ALTER SEQUENCE hr.employees_employee_id_seq OWNED BY hr.employees.employee_id;


--
-- Name: project_members; Type: TABLE; Schema: project; Owner: postgres
--

CREATE TABLE project.project_members (
    project_id integer NOT NULL,
    employee_id integer NOT NULL,
    role character varying(100),
    assigned_date date DEFAULT CURRENT_DATE
);


ALTER TABLE project.project_members OWNER TO postgres;

--
-- Name: TABLE project_members; Type: COMMENT; Schema: project; Owner: postgres
--

COMMENT ON TABLE project.project_members IS 'プロジェクトメンバー割り当て';


--
-- Name: projects; Type: TABLE; Schema: project; Owner: postgres
--

CREATE TABLE project.projects (
    project_id integer NOT NULL,
    project_name character varying(200) NOT NULL,
    description text,
    start_date date,
    end_date date,
    status character varying(50) DEFAULT 'active'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE project.projects OWNER TO postgres;

--
-- Name: TABLE projects; Type: COMMENT; Schema: project; Owner: postgres
--

COMMENT ON TABLE project.projects IS 'プロジェクト情報';


--
-- Name: projects_project_id_seq; Type: SEQUENCE; Schema: project; Owner: postgres
--

CREATE SEQUENCE project.projects_project_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE project.projects_project_id_seq OWNER TO postgres;

--
-- Name: projects_project_id_seq; Type: SEQUENCE OWNED BY; Schema: project; Owner: postgres
--

ALTER SEQUENCE project.projects_project_id_seq OWNED BY project.projects.project_id;


--
-- Name: departments department_id; Type: DEFAULT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.departments ALTER COLUMN department_id SET DEFAULT nextval('hr.departments_department_id_seq'::regclass);


--
-- Name: employees employee_id; Type: DEFAULT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.employees ALTER COLUMN employee_id SET DEFAULT nextval('hr.employees_employee_id_seq'::regclass);


--
-- Name: projects project_id; Type: DEFAULT; Schema: project; Owner: postgres
--

ALTER TABLE ONLY project.projects ALTER COLUMN project_id SET DEFAULT nextval('project.projects_project_id_seq'::regclass);


--
-- Name: departments departments_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.departments
    ADD CONSTRAINT departments_pkey PRIMARY KEY (department_id);


--
-- Name: employees employees_email_key; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.employees
    ADD CONSTRAINT employees_email_key UNIQUE (email);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (employee_id);


--
-- Name: project_members project_members_pkey; Type: CONSTRAINT; Schema: project; Owner: postgres
--

ALTER TABLE ONLY project.project_members
    ADD CONSTRAINT project_members_pkey PRIMARY KEY (project_id, employee_id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: project; Owner: postgres
--

ALTER TABLE ONLY project.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (project_id);


--
-- Name: idx_employees_department; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX idx_employees_department ON hr.employees USING btree (department_id);


--
-- Name: idx_employees_email; Type: INDEX; Schema: hr; Owner: postgres
--

CREATE INDEX idx_employees_email ON hr.employees USING btree (email);


--
-- Name: idx_projects_status; Type: INDEX; Schema: project; Owner: postgres
--

CREATE INDEX idx_projects_status ON project.projects USING btree (status);


--
-- Name: employees fk_employee_department; Type: FK CONSTRAINT; Schema: hr; Owner: postgres
--

ALTER TABLE ONLY hr.employees
    ADD CONSTRAINT fk_employee_department FOREIGN KEY (department_id) REFERENCES hr.departments(department_id) ON DELETE SET NULL;


--
-- Name: project_members fk_project_member_employee; Type: FK CONSTRAINT; Schema: project; Owner: postgres
--

ALTER TABLE ONLY project.project_members
    ADD CONSTRAINT fk_project_member_employee FOREIGN KEY (employee_id) REFERENCES hr.employees(employee_id) ON DELETE CASCADE;


--
-- Name: project_members fk_project_member_project; Type: FK CONSTRAINT; Schema: project; Owner: postgres
--

ALTER TABLE ONLY project.project_members
    ADD CONSTRAINT fk_project_member_project FOREIGN KEY (project_id) REFERENCES project.projects(project_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

