--BEGIN
--    FOR rec IN (SELECT table_name FROM user_tables) LOOP
--        EXECUTE IMMEDIATE 'DROP TABLE ' || rec.table_name || ' CASCADE CONSTRAINTS';
--    END LOOP;
--END;


CREATE TABLE FEDERACAO(
	NOME VARCHAR2(15),
	DATA_FUND DATE NOT NULL,
	CONSTRAINT PK_FEDERACAO PRIMARY KEY (NOME)
);
CREATE TABLE NACAO(
	NOME VARCHAR2(15),
	QTD_PLANETAS NUMBER,
	FEDERACAO VARCHAR2(15),
	CONSTRAINT PK_NACAO PRIMARY KEY (NOME),
	CONSTRAINT FK_NACAO_FEDERACAO FOREIGN KEY (FEDERACAO) REFERENCES FEDERACAO(NOME) ON DELETE SET NULL,
	CONSTRAINT CK_NACAO_QTD_PLANETAS CHECK (QTD_PLANETAS >= 0) -- >= 0 para poder manter o histórico de nações extintas
);
CREATE TABLE PLANETA(
	ID_ASTRO VARCHAR2(15),
	MASSA NUMBER,
	RAIO NUMBER,
	CLASSIFICACAO VARCHAR2(63),
	CONSTRAINT PK_PLANETA PRIMARY KEY (ID_ASTRO),
	CONSTRAINT CK_PLANETA_MASSA CHECK (MASSA > 0),
	CONSTRAINT CK_PLANETA_RAIO CHECK (RAIO > 0)
);
CREATE TABLE ESPECIE(
	NOME VARCHAR2(15),
	PLANETA_OR VARCHAR2(15),
	INTELIGENTE CHAR(1),
	CONSTRAINT PK_ESPECIE PRIMARY KEY (NOME),
	CONSTRAINT FK_ESPECIE_PLANETA FOREIGN KEY (PLANETA_OR) REFERENCES PLANETA(ID_ASTRO) ON DELETE CASCADE,
	CONSTRAINT CK_ESPECIE_INTELIGENTE CHECK (INTELIGENTE IN ('V', 'F'))
);
CREATE TABLE LIDER(
	CPI CHAR(14),
	NOME VARCHAR2(15),
	CARGO CHAR(10) NOT NULL,
	NACAO VARCHAR2(15) NOT NULL,
	ESPECIE VARCHAR2(15) NOT NULL,
	CONSTRAINT PK_LIDER PRIMARY KEY (CPI),
	CONSTRAINT FK_LIDER_NACAO FOREIGN KEY (NACAO) REFERENCES NACAO(NOME) ON DELETE CASCADE,
	CONSTRAINT FK_LIDER_ESPECIE FOREIGN KEY (ESPECIE) REFERENCES ESPECIE(NOME) ON DELETE CASCADE,
	CONSTRAINT CK_LIDER_CPI CHECK (REGEXP_LIKE(CPI, '^\d{3}\.\d{3}\.\d{3}-\d{2}$')),
	CONSTRAINT CK_LIDER_CARGO CHECK (CARGO IN ('COMANDANTE', 'OFICIAL', 'CIENTISTA')) -- Uppercase para padronização
);
CREATE TABLE FACCAO(
	NOME VARCHAR2(15),
	LIDER CHAR(14) NOT NULL,
	IDEOLOGIA VARCHAR2(15),
	QTD_NACOES NUMBER,
	CONSTRAINT PK_FACCAO PRIMARY KEY (NOME),
	CONSTRAINT FK_FACCAO_LIDER FOREIGN KEY (LIDER) REFERENCES LIDER(CPI),
	CONSTRAINT CK_FACCAO_IDEOLOGIA CHECK (
		IDEOLOGIA IN ('PROGRESSITA', 'TOTALITARIA', 'TRADICIONALISTA')
	),
	CONSTRAINT CK_FACCAO_QTD_NACOES CHECK (QTD_NACOES >= 0),
	-- >= 0 para poder manter o histórico de facções extintas
	CONSTRAINT UN_FACCAO_LIDER UNIQUE (LIDER)
);
CREATE TABLE NACAO_FACCAO(
	NACAO VARCHAR2(15),
	FACCAO VARCHAR2(15),
	CONSTRAINT PK_NF PRIMARY KEY (NACAO, FACCAO),
	CONSTRAINT FK_NF_NACAO FOREIGN KEY (NACAO) REFERENCES NACAO(NOME) ON DELETE CASCADE,
	CONSTRAINT FK_NF_FACCAO FOREIGN KEY (FACCAO) REFERENCES FACCAO(NOME) ON DELETE CASCADE
);


CREATE TABLE ESTRELA(
	ID_ESTRELA VARCHAR2(31),
	NOME VARCHAR2(31),
	CLASSIFICACAO VARCHAR2(31),
	MASSA NUMBER,
	X NUMBER NOT NULL,
	Y NUMBER NOT NULL,
	Z NUMBER NOT NULL,
	CONSTRAINT PK_ESTRELA PRIMARY KEY (ID_ESTRELA),
	CONSTRAINT CK_ESTRELA_MASSA CHECK (MASSA > 0),
	CONSTRAINT UN_ESTRELA_COORDS UNIQUE (X, Y, Z)
);
CREATE TABLE COMUNIDADE(
	ESPECIE VARCHAR2(15),
	NOME VARCHAR2(15),
	QTD_HABITANTES NUMBER NOT NULL,
	CONSTRAINT PK_COMUNIDADE PRIMARY KEY (ESPECIE, NOME),
	CONSTRAINT CK_COMUNIDADE_QTD_HABITANTES CHECK (QTD_HABITANTES >= 0),
	-- >= 0 para poder manter o histórico de comunidades extintas
	CONSTRAINT FK_COMUNIDADE_ESPECIE FOREIGN KEY (ESPECIE) REFERENCES ESPECIE(NOME) ON DELETE CASCADE
);
CREATE TABLE PARTICIPA(
	FACCAO VARCHAR2(15),
	ESPECIE VARCHAR2(15),
	COMUNIDADE VARCHAR2(15),
	CONSTRAINT PK_PARTICIPA PRIMARY KEY (FACCAO, ESPECIE, COMUNIDADE),
	CONSTRAINT FK_PARTICIPA_FACCAO FOREIGN KEY (FACCAO) REFERENCES FACCAO(NOME) ON DELETE CASCADE,
	CONSTRAINT FK_PARTICIPA_COMUNIDADE FOREIGN KEY (ESPECIE, COMUNIDADE) REFERENCES COMUNIDADE(ESPECIE, NOME) ON DELETE CASCADE
);
CREATE TABLE HABITACAO(
	PLANETA VARCHAR2(15),
	ESPECIE VARCHAR2(15),
	COMUNIDADE VARCHAR2(15),
	DATA_INI DATE,
	DATA_FIM DATE,
	CONSTRAINT PK_HABITACAO PRIMARY KEY (PLANETA, ESPECIE, COMUNIDADE, DATA_INI),
	CONSTRAINT FK_HABITACAO_PLANETA FOREIGN KEY (PLANETA) REFERENCES PLANETA(ID_ASTRO),
	CONSTRAINT FK_HABITACAO_COMUNIDADE FOREIGN KEY (ESPECIE, COMUNIDADE) REFERENCES COMUNIDADE(ESPECIE, NOME),
	CONSTRAINT CK_HABITACAO_DATA CHECK (
		DATA_FIM IS NULL
		OR DATA_FIM > DATA_INI
	)
);
CREATE TABLE DOMINANCIA(
	PLANETA VARCHAR2(15),
	NACAO VARCHAR2(15),
	DATA_INI DATE,
	DATA_FIM DATE,
	CONSTRAINT PK_DOMINANCIA PRIMARY KEY (NACAO, PLANETA, DATA_INI),
	CONSTRAINT FK_DOMINANCIA_NACAO FOREIGN KEY (NACAO) REFERENCES NACAO(NOME),
	CONSTRAINT FK_DOMINANCIA_PLANETA FOREIGN KEY (PLANETA) REFERENCES PLANETA(ID_ASTRO),
	CONSTRAINT CK_DOMINANCIA_DATA CHECK (
		DATA_FIM IS NULL
		OR DATA_FIM > DATA_INI
	)
);
CREATE TABLE SISTEMA(
	ESTRELA VARCHAR2(31),
	NOME VARCHAR2(31),
	CONSTRAINT PK_SISTEMA PRIMARY KEY (ESTRELA),
	CONSTRAINT FK_SISTEMA_ESTRELA FOREIGN KEY (ESTRELA) REFERENCES ESTRELA(ID_ESTRELA) ON DELETE CASCADE
);
CREATE TABLE ORBITA_ESTRELA(
	ORBITANTE VARCHAR2(31),
	ORBITADA VARCHAR2(31),
	DIST_MIN NUMBER,
	DIST_MAX NUMBER,
	PERIODO NUMBER,
	CONSTRAINT PK_OE PRIMARY KEY (ORBITANTE, ORBITADA),
	CONSTRAINT FK_OE_ORBITANTE FOREIGN KEY (ORBITANTE) REFERENCES ESTRELA(ID_ESTRELA) ON DELETE CASCADE,
	CONSTRAINT FK_OE_ORBITADA FOREIGN KEY (ORBITADA) REFERENCES ESTRELA(ID_ESTRELA) ON DELETE CASCADE,
	CONSTRAINT CK_OE_ORBITANTE_ORBITADA CHECK (ORBITANTE <> ORBITADA),
	CONSTRAINT CK_OE_DIST CHECK (DIST_MAX >= DIST_MIN),
	-- >= para permitir órbitas circulares
	CONSTRAINT CK_OE_PERIODO CHECK (PERIODO > 0)
);
CREATE TABLE ORBITA_PLANETA(
	PLANETA VARCHAR2(15),
	ESTRELA VARCHAR2(31),
	DIST_MIN NUMBER,
	DIST_MAX NUMBER,
	PERIODO NUMBER,
	CONSTRAINT PK_ORBITA_PLANETA PRIMARY KEY (PLANETA, ESTRELA),
	CONSTRAINT FK_OP_ESTRELA FOREIGN KEY (ESTRELA) REFERENCES ESTRELA(ID_ESTRELA) ON DELETE CASCADE,
	CONSTRAINT FK_OP_PLANETA FOREIGN KEY (PLANETA) REFERENCES PLANETA(ID_ASTRO) ON DELETE CASCADE,
	CONSTRAINT CK_OP_DIST CHECK (DIST_MAX >= DIST_MIN),
	-- >= para permitir órbitas circulares
	CONSTRAINT CK_OP_PERIODO CHECK (PERIODO > 0)
);

CREATE TABLE USERS (
    USER_ID NUMBER GENERATED ALWAYS AS IDENTITY,
    PASSWORD RAW(16),
    ID_LIDER CHAR(14),
    CONSTRAINT PK_USERS PRIMARY KEY (USER_ID),
    CONSTRAINT UQ_USERS_IdLider UNIQUE (ID_LIDER),
    CONSTRAINT FK_USERS_IdLider FOREIGN KEY (ID_LIDER) REFERENCES LIDER(CPI)
);

-- Tabela de log vai servir pra tudo, acessar sistema, inserir dados, rodar view etc
CREATE TABLE LOG_TABLE (
    USER_ID NUMBER,
    INCLUDED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    MESSAGE VARCHAR2(100),
    CONSTRAINT FK_LOG_TABLE_Userid FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID) ON DELETE CASCADE
);
