create database veterinaria;

use veterinaria;

create table paciente(
id_paciente int primary key auto_increment,
nome varchar (45) not null,
sobrenome varchar (45) not null,
Idade int not null,
especie varchar (50) not null);

CREATE TABLE Log_Consultas (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    custo_antigo DECIMAL(10, 2),
    custo_novo DECIMAL(10, 2),
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
);


create table veterinario(
id_veterinario int primary key auto_increment,
nome varchar (50) not null,
especialidade varchar (50) not null);

create table consultas(
id_consulta int primary key auto_increment,
id_paciente int,
id_veterinario int,
data_consulta date not null,
custo decimal (10,2) not null,
foreign key (id_paciente) references paciente(id_paciente),
foreign key (id_veterinario) references veterinario (id_veterinario));

insert into paciente values (3, 'Luna', 'Julia', -3, 'cachorro');

insert into veterinario values(1,'Enrico', 'vacina');

insert into consultas values(1,2,1,2024-10-23,25.00);
select * from  consultas;

select * from paciente

DELIMITER //

CREATE PROCEDURE agendar_consulta(
     id_paciente INT,
     id_veterinario INT,
     data_consulta DATE,
     custo DECIMAL(10, 2)
)
BEGIN
    -- Insere uma nova linha na tabela 'consultas'
    INSERT INTO consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (id_paciente, id_veterinario, data_consulta, custo);
END //

DELIMITER ;

CALL agendar_consulta(1, 1, '2024-10-01', 20.00);


DELIMITER //

CREATE PROCEDURE atualizar_paciente(
    IN p_id_paciente INT,
    IN p_novo_nome VARCHAR(45),
    IN p_nova_especie VARCHAR(50),
    IN p_nova_idade INT
)
BEGIN
    -- Atualiza o nome, a espécie e a idade do paciente com o id_paciente especificado
    UPDATE paciente
    SET nome = p_novo_nome,
        especie = p_nova_especie,
        idade = p_nova_idade
    WHERE id_paciente = p_id_paciente;
END //

DELIMITER ;

CALL atualizar_paciente(1, 'Antonia Silva', 'cachorro', 4);

DELIMITER //

CREATE PROCEDURE remover_consulta(
    IN p_id_consulta INT
)
BEGIN
    -- Remove a consulta com o id_consulta especificado
    DELETE FROM consultas
    WHERE id_consulta = p_id_consulta;
END //

DELIMITER ;

CALL remover_consulta(4);


DELIMITER //

CREATE FUNCTION total_gasto_paciente(
    p_id_paciente INT
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(10, 2);

    -- Calcula o total gasto pelo paciente em consultas
    SELECT COALESCE(SUM(custo), 0) INTO v_total
    FROM consultas
    WHERE id_paciente = p_id_paciente;

    RETURN v_total;
END //

DELIMITER ;

SELECT total_gasto_paciente(2);

DELIMITER //

CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON paciente
FOR EACH ROW
BEGIN
    -- Verifica se a idade do paciente é um número positivo
    IF NEW.Idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Idade do paciente deve ser um número positivo.';
    END IF;
END //

DELIMITER ;

DELIMITER //

CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON consultas
FOR EACH ROW
BEGIN
    -- Verifica se o custo foi alterado
    IF OLD.custo <> NEW.custo THEN
        -- Insere um registro na tabela de log com os detalhes da mudança
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (OLD.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //

DELIMITER ;


UPDATE consultas
SET custo = 30.00
WHERE id_consulta = 1;

SELECT * FROM Log_Consultas;

CREATE TABLE vacinas (
    id_vacina INT PRIMARY KEY AUTO_INCREMENT,
    nome_vacina VARCHAR(50) NOT NULL,
    especie VARCHAR(50) NOT NULL,
    periodo_validade INT NOT NULL -- em meses
);

insert into vacinas values (1, 'bezetacil', 'garganta', '01');

select * from vacinas;

CREATE TABLE historico_vacinacao (
    id_historico INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    id_vacina INT,
    data_vacinacao DATE NOT NULL,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_vacina) REFERENCES vacinas(id_vacina)
);

insert into historico_vacinacao values (1,1,1,2024/09/19);

select * from historico_vacinacao;

CREATE TABLE Log_Vacinacao (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_paciente INT,
    id_vacina INT,
    data_vacinacao DATE,
    mensagem TEXT,
    FOREIGN KEY (id_paciente) REFERENCES paciente(id_paciente),
    FOREIGN KEY (id_vacina) REFERENCES vacinas(id_vacina)
);

insert into log_vacinacao values (2,1,1,2024-09-10, 'vacinado');

select * from log_vacinacao;

CREATE TABLE prescricoes (
    id_prescricao INT PRIMARY KEY AUTO_INCREMENT,
    id_consulta INT,
    data_prescricao DATE NOT NULL,
    FOREIGN KEY (id_consulta) REFERENCES consultas(id_consulta)
);

insert into prescricoes values (1,1,2024-05-15);

select * from prescricoes;


CREATE TABLE Log_Prescricoes (
    id_log INT PRIMARY KEY AUTO_INCREMENT,
    id_prescricao INT,
    id_medicamento INT,
    data_prescricao date,
    FOREIGN KEY (id_prescricao) REFERENCES prescricoes(id_prescricao),
    FOREIGN KEY (id_medicamento) REFERENCES medicamentos(id_medicamento)
);

insert into Log_Prescricoes values(1,1,1,2024-05-16);

select * from Log_Prescricoes;


insert into medicamentos values (1,'dorflex','10mg','bom');

select * from medicamentos;

CREATE TABLE medicamentos (
    id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nome_medicamento VARCHAR(50) NOT NULL,
    dosagem VARCHAR(50) NOT NULL,
    efeitos_colaterais TEXT
);
1
DELIMITER //

CREATE TRIGGER verificar_idade_atualizacao_paciente
BEFORE UPDATE ON paciente
FOR EACH ROW
BEGIN
    -- Verifica se a nova idade do paciente é um número positivo
    IF NEW.Idade <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Idade do paciente deve ser um número positivo.';
    END IF;
END //

DELIMITER ;
2
DELIMITER //

CREATE TRIGGER registrar_vacinacao
AFTER INSERT ON historico_vacinacao
FOR EACH ROW
BEGIN
    -- Insere um registro de log informando que uma vacinação foi realizada
    INSERT INTO Log_Vacinacao (id_paciente, id_vacina, data_vacinacao, mensagem)
    VALUES (NEW.id_paciente, NEW.id_vacina, NEW.data_vacinacao, CONCAT('Paciente ', NEW.id_paciente, ' foi vacinado com ', NEW.id_vacina, ' em ', NEW.data_vacinacao));
END //

DELIMITER ;

3
DELIMITER //

CREATE TRIGGER log_prescricao
AFTER INSERT ON prescricoes
FOR EACH ROW
BEGIN
    -- Insere um log informando que um medicamento foi prescrito
    INSERT INTO Log_Prescricoes (id_prescricao, id_medicamento, id_consulta, data_prescricao, mensagem)
    VALUES (NEW.id_prescricao, NEW.id_medicamento, NEW.id_consulta, CURDATE(), 
            CONCAT('Medicamento ', NEW.id_medicamento, ' foi prescrito na consulta ', NEW.id_consulta));
END //

DELIMITER ;

4
DELIMITER //

CREATE TRIGGER atualizar_total_gasto
AFTER INSERT ON consultas
FOR EACH ROW
BEGIN
    -- Atualiza o total gasto pelo paciente
    UPDATE paciente
    SET total_gasto = total_gasto + NEW.custo -- Assumindo que a tabela paciente possui uma coluna total_gasto
    WHERE id_paciente = NEW.id_paciente;
END //

DELIMITER ;
5
DELIMITER //

CREATE TRIGGER remover_prescricao
AFTER DELETE ON medicamentos
FOR EACH ROW
BEGIN
    -- Remove todas as prescrições relacionadas ao medicamento excluído
    DELETE FROM prescricoes
    WHERE id_medicamento = OLD.id_medicamento;
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE adicionar_paciente(
    IN p_nome VARCHAR(45),
    IN p_sobrenome VARCHAR(45),
    IN p_idade INT,
    IN p_especie VARCHAR(50)
)
BEGIN
    INSERT INTO paciente (nome, sobrenome, idade, especie)
    VALUES (p_nome, p_sobrenome, p_idade, p_especie);
END //

DELIMITER ;

CALL adicionar_paciente('Rex', 'Almeida', 5, 'cachorro');


DELIMITER //

CREATE PROCEDURE registrar_vacinacao(
    IN p_id_paciente INT,
    IN p_id_vacina INT,
    IN p_data_vacinacao DATE
)
BEGIN
    INSERT INTO historico_vacinacao (id_paciente, id_vacina, data_vacinacao)
    VALUES (p_id_paciente, p_id_vacina, p_data_vacinacao);
END //

DELIMITER ;

CALL registrar_vacinacao(1, 1, '2024-09-19');

DELIMITER //

CREATE PROCEDURE atualizar_custo_consulta(
    IN p_id_consulta INT,
    IN p_novo_custo DECIMAL(10, 2)
)
BEGIN
    UPDATE consultas
    SET custo = p_novo_custo
    WHERE id_consulta = p_id_consulta;
END //

DELIMITER ;

CALL atualizar_custo_consulta(1, 35.00);

DELIMITER //

CREATE PROCEDURE listar_consultas_paciente(
    IN p_id_paciente INT
)
BEGIN
    SELECT * FROM consultas
    WHERE id_paciente = p_id_paciente;
END //

DELIMITER ;

call listar_consultas_paciente (1);

call remover_paciente(3);

select * from paciente