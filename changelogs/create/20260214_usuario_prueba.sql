-- =========================
-- 4) PERSONAS (UPSERT por DNI)
-- =========================
INSERT INTO PERSONAS (
  PER_NOMBRES, PER_APELLIDO, PER_FECHA_NACIMIENTO,
  PER_DNI, PER_EMAIL, PER_DIRECCION,
  aud_usr_ins, aud_usr_upd
)
VALUES
  ('Roberta', 'Ambroggio', '1985-03-10', '30111222', 'roberta@bls.edu.ar', 'Av. Libertador 123', 'SYS', 'SYS'),
  ('Luisina', 'Abratte',   '1988-07-21', '30999888', 'luisina@bls.edu.ar', 'Belgrano 456',       'SYS', 'SYS'),
  ('Romina',  'Brizzio',   '1990-11-02', '32123456', 'romina@bls.edu.ar',  'San Martín 789',     'SYS', 'SYS')
ON CONFLICT (PER_DNI) DO UPDATE SET
  PER_NOMBRES = EXCLUDED.PER_NOMBRES,
  PER_APELLIDO = EXCLUDED.PER_APELLIDO,
  PER_FECHA_NACIMIENTO = EXCLUDED.PER_FECHA_NACIMIENTO,
  PER_EMAIL = EXCLUDED.PER_EMAIL,
  PER_DIRECCION = EXCLUDED.PER_DIRECCION,
  aud_usr_upd = 'SYS',
  aud_fecha_upd = CURRENT_TIMESTAMP;

  -- =========================
-- 5) USUARIOS (si no existen por username)
--    bcrypt:
--      admin123 -> $2b$10$9GkfEMx0pgEo7GZPBTV3L.4YcrXDOykEhbPV/IAjVyqsYuY0ISs0y
--      la.123   -> $2b$10$1sCMYzWLCOL613af8/hVZOENA4Zd7MScBN5sTIV18/eWzntj6R5Ea
--      rb.123   -> $2b$10$DHbE1KLj4irQi7zj3dJNDu.OAjcv5PimS6rpBcMBSvaI8CsoZ715i
-- =========================

-- ROBERTA (admin)
INSERT INTO USUARIOS (
  USR_USERNAME, USR_PASSWORD, USR_ACTIVO, USR_ULT_LOGIN,
  aud_usr_ins, aud_usr_upd, USR_PER_ID
)
SELECT
  'rambroggio',
  '$2b$10$9GkfEMx0pgEo7GZPBTV3L.4YcrXDOykEhbPV/IAjVyqsYuY0ISs0y',
  TRUE,
  NULL,
  'SYS',
  'SYS',
  p.PER_ID
FROM PERSONAS p
WHERE p.PER_DNI = '30111222'
  AND NOT EXISTS (SELECT 1 FROM USUARIOS u WHERE u.USR_USERNAME = 'rambroggio');

-- LUISINA (admin + docente)
INSERT INTO USUARIOS (
  USR_USERNAME, USR_PASSWORD, USR_ACTIVO, USR_ULT_LOGIN,
  aud_usr_ins, aud_usr_upd, USR_PER_ID
)
SELECT
  'labratte',
  '$2b$10$1sCMYzWLCOL613af8/hVZOENA4Zd7MScBN5sTIV18/eWzntj6R5Ea',
  TRUE,
  NULL,
  'SYS',
  'SYS',
  p.PER_ID
FROM PERSONAS p
WHERE p.PER_DNI = '30999888'
  AND NOT EXISTS (SELECT 1 FROM USUARIOS u WHERE u.USR_USERNAME = 'labratte');

-- ROMINA (docente)
INSERT INTO USUARIOS (
  USR_USERNAME, USR_PASSWORD, USR_ACTIVO, USR_ULT_LOGIN,
  aud_usr_ins, aud_usr_upd, USR_PER_ID
)
SELECT
  'rbrizzio',
  '$2b$10$DHbE1KLj4irQi7zj3dJNDu.OAjcv5PimS6rpBcMBSvaI8CsoZ715i',
  TRUE,
  NULL,
  'SYS',
  'SYS',
  p.PER_ID
FROM PERSONAS p
WHERE p.PER_DNI = '32123456'
  AND NOT EXISTS (SELECT 1 FROM USUARIOS u WHERE u.USR_USERNAME = 'rbrizzio');


  -- =========================
-- 6) Asignación de roles
-- =========================

-- Roberta -> ADMIN
INSERT INTO USUARIOS_ROLES (UR_USR_ID, UR_ROL_ID)
SELECT u.USR_ID, r.ROL_ID
FROM USUARIOS u
JOIN ROLES r ON r.ROL_NOMBRE = 'ADMIN'
WHERE u.USR_USERNAME = 'rambroggio'
ON CONFLICT DO NOTHING;

-- Luisina -> ADMIN + DOCENTE
INSERT INTO USUARIOS_ROLES (UR_USR_ID, UR_ROL_ID)
SELECT u.USR_ID, r.ROL_ID
FROM USUARIOS u
JOIN ROLES r ON r.ROL_NOMBRE IN ('ADMIN','DOCENTE')
WHERE u.USR_USERNAME = 'labratte'
ON CONFLICT DO NOTHING;

-- Romina -> DOCENTE
INSERT INTO USUARIOS_ROLES (UR_USR_ID, UR_ROL_ID)
SELECT u.USR_ID, r.ROL_ID
FROM USUARIOS u
JOIN ROLES r ON r.ROL_NOMBRE = 'DOCENTE'
WHERE u.USR_USERNAME = 'rbrizzio'
ON CONFLICT DO NOTHING;
