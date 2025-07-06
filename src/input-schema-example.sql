-- シンプルなスキーマ使用例
-- 部署と従業員を管理するシステム

-- 人事スキーマ
CREATE SCHEMA IF NOT EXISTS hr;

-- 部署テーブル
CREATE TABLE hr.departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 従業員テーブル
CREATE TABLE hr.employees (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    department_id INTEGER,
    hire_date DATE NOT NULL,
    salary DECIMAL(10, 2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_employee_department 
        FOREIGN KEY (department_id) 
        REFERENCES hr.departments(department_id)
        ON DELETE SET NULL
);

-- プロジェクト管理スキーマ
CREATE SCHEMA IF NOT EXISTS project;

-- プロジェクトテーブル
CREATE TABLE project.projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- プロジェクトメンバーテーブル（スキーマ間の参照）
CREATE TABLE project.project_members (
    project_id INTEGER NOT NULL,
    employee_id INTEGER NOT NULL,
    role VARCHAR(100),
    assigned_date DATE DEFAULT CURRENT_DATE,
    PRIMARY KEY (project_id, employee_id),
    CONSTRAINT fk_project_member_project 
        FOREIGN KEY (project_id) 
        REFERENCES project.projects(project_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_project_member_employee 
        FOREIGN KEY (employee_id) 
        REFERENCES hr.employees(employee_id)
        ON DELETE CASCADE
);

-- インデックスの作成
CREATE INDEX idx_employees_department ON hr.employees(department_id);
CREATE INDEX idx_employees_email ON hr.employees(email);
CREATE INDEX idx_projects_status ON project.projects(status);

-- コメントの追加
COMMENT ON SCHEMA hr IS '人事管理スキーマ';
COMMENT ON SCHEMA project IS 'プロジェクト管理スキーマ';
COMMENT ON TABLE hr.departments IS '部署マスタ';
COMMENT ON TABLE hr.employees IS '従業員マスタ';
COMMENT ON TABLE project.projects IS 'プロジェクト情報';
COMMENT ON TABLE project.project_members IS 'プロジェクトメンバー割り当て';