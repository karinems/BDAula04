/*
Tarefas Stored Procedure:
Criar uma database chamada cadastro, criar uma tabela pessoa (CPF CHAR(11) PK, nome VARCHAR(80)), pegar o algoritmo de validação de CPF, 
transformar em uma Stored Procedure sp_inserepessoa, que receba como parâmetro @cpf e @nome e @saida como parâmtero de saída. 
Valide o CPF e, só insira na tabela pessoa (cpf e nome) com CPF válido e nome com LEN Maior que zero. 
@saida deve dizer que foi inserido com sucesso. Raiserrors devem tratar violações. 
*/

CREATE DATABASE cadastro
GO
USE cadastro

CREATE TABLE pessoa (
cpf		CHAR(11) NOT NULL,
nome	VARCHAR(80) NOT NULL
PRIMARY KEY(cpf)
)

CREATE PROCEDURE sp_inserepessoa (@cpf CHAR(11), @nome VARCHAR(80), @saida VARCHAR(MAX) OUTPUT) 
AS

-- Algoritmo do CPF

-- Apesar de satisfazer o algoritmo, cpf com todos os números iguais devem ser considerados inválidos

IF (@cpf = '00000000000' OR @cpf = '11111111111' OR @cpf = '22222222222' OR @cpf = '33333333333' OR 
	@cpf = '44444444444' OR @cpf = '55555555555' OR @cpf = '66666666666' OR @cpf = '77777777777' OR
	@cpf = '88888888888' OR @cpf = '99999999999')
BEGIN
	RAISERROR('CPF invalido, todos os numeros estao iguais', 16, 1)
END
ELSE
BEGIN
	PRINT 'O CPF: ' + SUBSTRING(@cpf, 1, 9) + '-' + SUBSTRING(@cpf, 10, 2) + ' terá os dígitos verificadores testados'
DECLARE 
		@j				AS INT,
		@aux			AS INT,
		@multiplica		AS INT, 
		@somatorio		AS INT


SET @j = 10
SET @aux = 1
SET @somatorio = 0

-- Calculando o primeiro dígito verificador

WHILE (@j > 1)
BEGIN
	SET @multiplica = (@j * SUBSTRING(@cpf, @aux, 1))
	SET @somatorio = @somatorio + @multiplica
	SET @j = @j - 1
	SET @aux = @aux + 1
END

-- Verificando se o primeiro dígito verificador é válido

IF (@somatorio % 11 < 2)
BEGIN
	IF (SUBSTRING(@cpf, 10, 1) = 0)
	BEGIN
		PRINT 'Primeiro dígito verificador válido'
	END
	ELSE
	BEGIN
		RAISERROR('CPF invalido, primeiro digito verificador nao esta correto', 16, 1)
	END
END
ELSE
BEGIN
	IF (SUBSTRING(@cpf, 10, 1) = 11 - @somatorio % 11)
	BEGIN
		PRINT 'Primeiro dígito verificador válido'
	END
	ELSE
	BEGIN
		RAISERROR('CPF invalido, primeiro digito verificador nao esta correto', 16, 1)
	END
END

-- Calculando o segundo dígito verificador

SET @j = 11
SET @aux = 1
SET @somatorio = 0

WHILE (@j > 1)
BEGIN
	SET @multiplica = (@j * SUBSTRING(@cpf, @aux, 1))
	SET @somatorio = @somatorio + @multiplica
	SET @j = @j - 1
	SET @aux = @aux + 1
END

-- Verificando se o segundo dígito verificador é válido

IF (@somatorio % 11 < 2)
BEGIN
	IF (SUBSTRING(@cpf, 11, 1) = 0)
	BEGIN
		PRINT 'Segundo dígito verificador válido'
		IF (LEN(@nome) > 0)
		BEGIN
			INSERT INTO pessoa 
			VALUES (@cpf, @nome)
			PRINT 'O CPF: ' + SUBSTRING(@cpf, 1, 9) + '-' + SUBSTRING(@cpf, 10, 2) + ' é válido'
			SET @saida = 'Pessoa inserida com sucesso'
		END
		ELSE
		BEGIN
			RAISERROR('Nome invalido', 16, 1)
		END
	END
	ELSE
	BEGIN
		RAISERROR('CPF invalido, segundo digito verificador nao esta correto', 16, 1)
	END
END
ELSE
BEGIN
	IF (SUBSTRING(@cpf, 11, 1) = 11 - @somatorio % 11)
	BEGIN
		PRINT 'Segundo dígito verificador válido'
		IF (LEN(@nome) > 0)
		BEGIN
			INSERT INTO pessoa 
			VALUES (@cpf, @nome)
			PRINT 'O CPF: ' + SUBSTRING(@cpf, 1, 9) + '-' + SUBSTRING(@cpf, 10, 2) + ' é válido'
			SET @saida = 'Pessoa inserida com sucesso'
		END
		ELSE
		BEGIN
			RAISERROR('Nome invalido', 16, 1)
		END
	END
	ELSE
	BEGIN
		RAISERROR('CPF invalido, segundo digito verificador nao esta correto', 16, 1)
	END
END
END

--Insert de pessoa válida
DECLARE @out VARCHAR(MAX)
EXEC sp_inserepessoa '22233366638', 'Fulano', @out OUTPUT
PRINT @out

--Insert de pessoa inválida
DECLARE @out VARCHAR(MAX)
EXEC sp_inserepessoa '22222222222', 'Ciclano', @out OUTPUT
PRINT @out

SELECT * FROM pessoa

/*Exercício
Criar uma database chamada academia, com 3 tabelas como seguem:
Aluno
|Codigo_aluno|Nome|
Atividade
|Codigo|Descrição|IMC|
Atividade
codigo      descricao                           imc
----------- ----------------------------------- --------
1           Corrida + Step                       18.5
2           Biceps + Costas + Pernas             24.9
3           Esteira + Biceps + Costas + Pernas   29.9
4           Bicicleta + Biceps + Costas + Pernas 34.9
5           Esteira + Bicicleta                  39.9                                                                                                                                                                    
Atividadesaluno
|Codigo_aluno|Altura|Peso|IMC|Atividade|
IMC = Peso (Kg) / Altura² (M)
Atividade: Buscar a PRIMEIRA atividade referente ao IMC imediatamente acima do calculado.
* Caso o IMC seja maior que 40, utilizar o código 5.
Criar uma Stored Procedure (sp_alunoatividades), com as seguintes regras:
 - Se, dos dados inseridos, o código for nulo, mas, existirem nome, altura, peso, deve-se inserir um 
 novo registro nas tabelas aluno e aluno atividade com o imc calculado e as atividades pelas 
 regras estabelecidas acima.
 - Se, dos dados inseridos, o nome for (ou não nulo), mas, existirem código, altura, peso, deve-se 
 verificar se aquele código existe na base de dados e atualizar a altura, o peso, o imc calculado e 
 as atividades pelas regras estabelecidas acima.
*/

CREATE DATABASE academia
GO
USE academia

CREATE TABLE aluno (
codigo_aluno INT,
nome VARCHAR(80)
)

CREATE TABLE atividade (
codigo INT NOT NULL,
descricao VARCHAR(80) NOT NULL,
imc DECIMAL(7,2) NOT NULL
PRIMARY KEY (codigo)
)

INSERT INTO atividade VALUES
(1, 'Corrida + Step', 18.5), 
(2, 'Biceps + Costas + Pernas', 24.9),
(3, 'Esteira + Biceps + Costas + Pernas', 29.9),
(4, 'Bicicleta + Biceps + Costas + Pernas', 34.9),
(5, 'Esteira + Bicicleta', 39.9)

CREATE TABLE atividade_aluno (
codigo_aluno INT,
altura DECIMAL(7,2),
peso DECIMAL(7,2),
imc DECIMAL (7,2),
atividade VARCHAR(80)
)

CREATE PROCEDURE sp_alunoatividades (@codigo_aluno INT, @nome VARCHAR(80), @altura DECIMAL(7,2),
@peso DECIMAL(7,2), @saida VARCHAR(MAX) OUTPUT) 
AS
DECLARE 
		@imc AS INT,
		@atividade AS VARCHAR(80)

DECLARE @prox_cod INT

IF (@codigo_aluno IS NULL AND @nome IS NOT NULL AND @altura IS NOT NULL AND @peso IS NOT NULL)
BEGIN
	PRINT 'O código digitado é nulo, mas apresenta outros dados. Código será auto incrementado e valores serão inseridos'
	EXEC sp_prox_cod_aluno @prox_cod OUTPUT
	INSERT INTO aluno 
	VALUES (@prox_cod, @nome)
	SET @imc = @peso / (@altura * @altura)
	IF (@imc < 24.9)
	BEGIN
		SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 1)
	END
	IF (@imc >= 24.9 AND @imc < 29.9)
	BEGIN
		SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 2)
	END
	IF (@imc >= 29.9 AND @imc < 34.9)
	BEGIN
		SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 3)
	END
	IF (@imc >= 34.9 AND @imc < 39.9)
	BEGIN
		SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 4)
	END
	IF (@imc >= 39.9)
	BEGIN
		SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 5)
	END
	INSERT INTO atividade_aluno
	VALUES (@prox_cod, @altura, @peso, @imc, @atividade)
	SET @saida = 'Aluno inserido'
END
ELSE
BEGIN
	IF (@codigo_aluno IS NOT NULL AND @altura IS NOT NULL AND @peso IS NOT NULL)
	BEGIN
		IF (@codigo_aluno = (SELECT codigo_aluno FROM aluno WHERE codigo_aluno = @codigo_aluno))
		BEGIN
		PRINT 'O código já está no sistema, será atualizado seus dados, exceto o nome'
		SET @imc = @peso / (@altura * @altura)
		IF (@imc < 24.9)
		BEGIN
			SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 1)
		END
		IF (@imc >= 24.9 AND @imc < 29.9)
		BEGIN
			SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 2)
		END
		IF (@imc >= 29.9 AND @imc < 34.9)
		BEGIN
			SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 3)
		END
		IF (@imc >= 34.9 AND @imc < 39.9)
		BEGIN
			SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 4)
		END
		IF (@imc >= 39.9)
		BEGIN
			SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 5)
		END
		UPDATE atividade_aluno 
		SET altura = @altura, peso = @peso, imc = @imc, atividade = @atividade
		WHERE codigo_aluno = @codigo_aluno
		SET @saida = 'Aluno atualizado com sucesso'
		END
		IF (@codigo_aluno IS NOT NULL AND @nome IS NOT NULL OR @nome IS NULL AND @altura IS NOT NULL AND @peso IS NOT NULL)
		BEGIN
			IF (@codigo_aluno = (SELECT codigo_aluno FROM aluno WHERE codigo_aluno = @codigo_aluno))
			BEGIN
				RAISERROR('Codigo do aluno ja esta no sistema', 16, 1)
			END
			ELSE
			BEGIN
				INSERT INTO aluno 
				VALUES (@codigo_aluno, @nome)
				SET @imc = @peso / (@altura * @altura)
				IF (@imc < 24.9)
				BEGIN
					SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 1)
				END
				IF (@imc >= 24.9 AND @imc < 29.9)
				BEGIN
					SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 2)
				END
				IF (@imc >= 29.9 AND @imc < 34.9)
				BEGIN
					SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 3)
				END
				IF (@imc >= 34.9 AND @imc < 39.9)
				BEGIN
					SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 4)
				END
				IF (@imc >= 39.9)
				BEGIN
					SET @atividade = (SELECT descricao FROM atividade WHERE codigo = 5)
				END
					INSERT INTO atividade_aluno
					VALUES (@codigo_aluno, @altura, @peso, @imc, @atividade)
					SET @saida = 'Aluno inserido'
			END
		END
	END
END

-- Insert de aluno válido com código null
DECLARE @out VARCHAR(MAX)
EXEC sp_alunoatividades NULL, 'Aluno1', 1.80, 72.0, @out OUTPUT
PRINT @out

-- Insert de aluno válido
DECLARE @out VARCHAR(MAX)
EXEC sp_alunoatividades 3, 'Aluno2', 1.70, 105.0, @out OUTPUT
PRINT @out

-- Insert de aluno com nome null
DECLARE @out VARCHAR(MAX)
EXEC sp_alunoatividades 4, NULL, 1.50, 100.0, @out OUTPUT
PRINT @out

-- Select para mostrar a tabela aluno e atividade_aluno
SELECT a.codigo_aluno, a.nome, aa.altura, aa.peso, aa.imc, aa.atividade 
FROM atividade_aluno aa INNER JOIN aluno a
ON a.codigo_aluno = aa.codigo_aluno
ORDER BY a.codigo_aluno, a.nome 

-- Código de auto incremento

CREATE PROCEDURE sp_prox_cod_aluno(@cod INT OUTPUT)
AS
	DECLARE @count INT
	SET @count = (SELECT COUNT(*) FROM aluno)
	IF (@count = 0)
	BEGIN
		SET @cod = 1
	END
	ELSE
	BEGIN
		SET @cod = (SELECT MAX(codigo_aluno) FROM aluno) + 1
	END