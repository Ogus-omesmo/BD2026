-- SEÇÃO 1: LIMPAR DADOS ANTIGOS (Execute uma vez)
-- Remove tabelas e função se existirem, para recriá-las do zero

IF OBJECT_ID('dbo.Contas_A_Receber', 'U') IS NOT NULL DROP TABLE dbo.Contas_A_Receber
IF OBJECT_ID('dbo.Feriados_Do_Ano', 'U') IS NOT NULL DROP TABLE dbo.Feriados_Do_Ano
IF OBJECT_ID('dbo.Feriados_Fixos', 'U') IS NOT NULL DROP TABLE dbo.Feriados_Fixos
IF OBJECT_ID('dbo.Saldo', 'U') IS NOT NULL DROP TABLE dbo.Saldo
IF OBJECT_ID('dbo.Compra', 'U') IS NOT NULL DROP TABLE dbo.Compra
IF OBJECT_ID('dbo.Venda', 'U') IS NOT NULL DROP TABLE dbo.Venda
IF OBJECT_ID('dbo.Produto', 'U') IS NOT NULL DROP TABLE dbo.Produto
IF OBJECT_ID('dbo.fn_ProximoDiaUtil', 'FN') IS NOT NULL DROP FUNCTION dbo.fn_ProximoDiaUtil

GO

-- SEÇÃO 2: CRIAR TABELA PRODUTO
-- Armazena produtos com ID automático (identity)

CREATE TABLE Produto
(
	ID_Produto int primary key identity(1,1),
	Descricao nvarchar(40) NOT NULL,
	Unidade varchar(2),
	Preco float NOT NULL
)

GO

-- SEÇÃO 3: CRIAR TABELA VENDA
-- Registra vendas com FK para Produto

CREATE TABLE Venda
(
	ID_Venda int primary key identity(1,1),
	Data_Venda date NOT NULL,
	ID_Cliente int NOT NULL,
	ID_Produto int NOT NULL,
	QTD_Venda int NOT NULL,
	Valor_Total decimal(10,2) NOT NULL,
	Numero_Parcelas int NOT NULL DEFAULT 1,
	constraint FK_Venda_Produto
	foreign key (ID_Produto)
	references Produto(ID_Produto)
)

GO

-- SEÇÃO 4: CRIAR TABELA COMPRA
-- Registra compras com FK para Produto (mesma estrutura da Venda)

CREATE TABLE Compra
(
	ID_Compra int primary key identity(1,1),
	Data_Compra date NOT NULL,
	ID_Cliente int NOT NULL,
	ID_Produto int NOT NULL,
	QTD_Compra int NOT NULL,
	Valor_Total decimal(10,2) NOT NULL,
	constraint FK_Compra_Produto
	foreign key (ID_Produto)
	references Produto(ID_Produto)
)

GO

-- SEÇÃO 5: CRIAR TABELA SALDO
-- Mantém o saldo (quantidade) de cada produto

CREATE TABLE Saldo
(
	ID_Produto int primary key,
	Saldo_Produto decimal(10,2) NOT NULL DEFAULT 0,
	constraint FK_Saldo_Produto
	foreign key (ID_Produto)
	references Produto(ID_Produto)
)

GO

-- SEÇÃO 6: CRIAR TABELA FERIADOS FIXOS
-- Feriados que se repetem todo ano (ex: Natal sempre em 25/12)

CREATE TABLE Feriados_Fixos
(
	ID_Feriado_Fixo int primary key identity(1,1),
	Dia int NOT NULL CHECK(Dia >= 1 AND Dia <= 31),
	Mes int NOT NULL CHECK(Mes >= 1 AND Mes <= 12),
	Descricao nvarchar(50) NOT NULL
)

GO

-- SEÇÃO 7: CRIAR TABELA FERIADOS DO ANO
-- Feriados móveis (ex: Carnaval, Páscoa) com data completa

CREATE TABLE Feriados_Do_Ano
(
	ID_Feriado_Ano int primary key identity(1,1),
	Data_Feriado date NOT NULL,
	Descricao nvarchar(50) NOT NULL
)

GO

-- SEÇÃO 8: CRIAR TABELA CONTAS A RECEBER
-- Armazena parcelas de vendas com datas de vencimento

CREATE TABLE Contas_A_Receber
(
	ID_Conta int primary key identity(1,1),
	ID_Venda int NOT NULL,
	Num_Parcela int NOT NULL,
	Data_Vencimento date NOT NULL,
	Valor_Parcela money NOT NULL,
	Data_Pagamento date NULL,
	constraint FK_CAR_Venda
	foreign key (ID_Venda)
	references Venda(ID_Venda)
)

GO

-- SEÇÃO 9: INSERIR PRODUTOS
-- Popula a tabela com 21 produtos de jogos e tecnologia

INSERT INTO Produto (Descricao, Unidade, Preco)
VALUES
('PlayStation 5', 'un', 4999.99),
('Xbox Series X', 'un', 4899.99),
('Nintendo Switch', 'un', 2999.00),
('Jogo Elden Ring', 'un', 299.90),
('Jogo The Last of Us', 'un', 249.90),
('Jogo Zelda Tears Kingdom', 'un', 359.90),
('Controle PS5 DualSense', 'un', 449.99),
('Headset Gamer HyperX', 'un', 549.99),
('Mouse Logitech G502', 'un', 389.90),
('Teclado Mecânico RGB', 'un', 599.99),
('Monitor 144Hz 27"', 'un', 1299.90),
('Webcam 1080p 60fps', 'un', 299.90),
('Mousepad Grande', 'un', 149.90),
('Suporte para Controle', 'un', 59.90),
('Cartucho Joy-Con', 'un', 349.90),
('Game Pass Anual', 'un', 199.90),
('PlayStation Plus 1 Ano', 'un', 249.90),
('Cable HDMI 2.1', 'un', 89.90),
('Protetor de Tela', 'un', 39.90),
('Capinha de Silicone', 'un', 79.90),
('Carregador Rápido USB-C', 'un', 199.90)

GO

-- SEÇÃO 10: INSERIR SALDO INICIAL
-- Cada produto começa com saldo de 100 unidades

INSERT INTO Saldo (ID_Produto, Saldo_Produto)
SELECT ID_Produto, 100 FROM Produto

GO

-- SEÇÃO 11: INSERIR FERIADOS FIXOS
-- Define feriados brasileiros que repetem todo ano (verifica apenas Dia/Mês)

INSERT INTO Feriados_Fixos (Dia, Mes, Descricao)
VALUES
(1, 1, 'Confraternização Universal'),
(21, 4, 'Tiradentes'),
(1, 5, 'Dia do Trabalho'),
(12, 10, 'Nossa Senhora Aparecida'),
(2, 11, 'Finados'),
(15, 11, 'Proclamação da República'),
(25, 12, 'Natal')

GO

-- SEÇÃO 12: INSERIR FERIADOS DO ANO
-- Define feriados móveis de 2026 (verifica data completa)

INSERT INTO Feriados_Do_Ano (Data_Feriado, Descricao)
VALUES
('2026-02-17', 'Carnaval'),
('2026-04-03', 'Paixão de Cristo'),
('2026-09-07', 'Independência do Brasil')

GO

-- SEÇÃO 13: CRIAR FUNÇÃO PRÓXIMO DIA ÚTIL
-- Calcula o próximo dia útil (não sábado, domingo ou feriado)
-- Recebe uma data e retorna a próxima data útil

CREATE FUNCTION dbo.fn_ProximoDiaUtil(@Data DATE)
RETURNS DATE
AS
BEGIN
    DECLARE @Dia_Semana INT
    DECLARE @Data_Teste DATE
    DECLARE @Max_Iteracoes INT = 365
    DECLARE @Contador INT = 0
    
    SET @Data_Teste = @Data
    
    -- Loop que continua até encontrar um dia útil
    WHILE @Contador < @Max_Iteracoes
    BEGIN
        SET @Dia_Semana = DATEPART(WEEKDAY, @Data_Teste)
        
        -- Se for fim de semana (1=domingo, 7=sábado), avança um dia
        IF @Dia_Semana = 1 OR @Dia_Semana = 7
        BEGIN
            SET @Data_Teste = DATEADD(DAY, 1, @Data_Teste)
            SET @Contador = @Contador + 1
            CONTINUE
        END
        
        -- Verifica se é feriado fixo (apenas dia e mês)
        IF EXISTS (SELECT 1 FROM Feriados_Fixos 
                   WHERE DAY(@Data_Teste) = Dia AND MONTH(@Data_Teste) = Mes)
        BEGIN
            SET @Data_Teste = DATEADD(DAY, 1, @Data_Teste)
            SET @Contador = @Contador + 1
            CONTINUE
        END
        
        -- Verifica se é feriado móvel (data completa)
        IF EXISTS (SELECT 1 FROM Feriados_Do_Ano 
                   WHERE Data_Feriado = @Data_Teste)
        BEGIN
            SET @Data_Teste = DATEADD(DAY, 1, @Data_Teste)
            SET @Contador = @Contador + 1
            CONTINUE
        END
        
        -- Se chegou aqui, é um dia útil, sai do loop
        BREAK
    END
    
    -- Segurança: se não encontrar em 365 dias, retorna a data original
    IF @Contador >= @Max_Iteracoes
        SET @Data_Teste = @Data
    
    RETURN @Data_Teste
END
GO

-- SEÇÃO 14: TRIGGER 1 - VENDA SUBTRAI SALDO
-- Ao inserir uma venda, subtrai a quantidade do saldo do produto
-- Valida quantidade > 0 e se há saldo suficiente

CREATE TRIGGER TR_Venda_SubtraiSaldo
ON Venda
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	
	-- Rejeita vendas com quantidade zero ou negativa
	IF EXISTS(SELECT 1 FROM inserted WHERE QTD_Venda <= 0)
	BEGIN
		RAISERROR('Quantidade de venda deve ser maior que zero', 16, 1)
		ROLLBACK
		RETURN
	END
	
	-- Rejeita vendas se não houver saldo suficiente
	IF EXISTS(SELECT 1 FROM inserted i 
	          WHERE NOT EXISTS(SELECT 1 FROM Saldo s 
	                          WHERE s.ID_Produto = i.ID_Produto 
	                          AND s.Saldo_Produto >= i.QTD_Venda))
	BEGIN
		RAISERROR('Saldo insuficiente para a venda', 16, 1)
		ROLLBACK
		RETURN
	END
	
	-- Reduz o saldo pela quantidade vendida
	UPDATE Saldo
	SET Saldo_Produto = Saldo_Produto - i.QTD_Venda
	FROM Saldo s
	INNER JOIN inserted i ON s.ID_Produto = i.ID_Produto
END
GO

-- SEÇÃO 15: TRIGGER 2 - COMPRA SOMA SALDO
-- Ao inserir uma compra, soma a quantidade ao saldo do produto
-- Valida quantidade > 0

CREATE TRIGGER TR_Compra_SomaSaldo
ON Compra
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	
	-- Rejeita compras com quantidade zero ou negativa
	IF EXISTS(SELECT 1 FROM inserted WHERE QTD_Compra <= 0)
	BEGIN
		RAISERROR('Quantidade de compra deve ser maior que zero', 16, 1)
		ROLLBACK
		RETURN
	END
	
	-- Aumenta o saldo pela quantidade comprada
	UPDATE Saldo
	SET Saldo_Produto = Saldo_Produto + i.QTD_Compra
	FROM Saldo s
	INNER JOIN inserted i ON s.ID_Produto = i.ID_Produto
END
GO

-- SEÇÃO 16: TRIGGER 3 - VENDA CRIA PARCELAS
-- Ao inserir uma venda, gera automaticamente as parcelas em Contas_A_Receber
-- Divide o valor total pela quantidade de parcelas
-- Calcula datas de vencimento como dias úteis

CREATE TRIGGER TR_Venda_CriaParcelas
ON Venda
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON
	
	-- Valida número de parcelas
	IF EXISTS(SELECT 1 FROM inserted WHERE Numero_Parcelas IS NULL OR Numero_Parcelas <= 0)
	BEGIN
		RAISERROR('Número de parcelas deve ser maior que zero', 16, 1)
		ROLLBACK
		RETURN
	END
	
	-- Valida valor total
	IF EXISTS(SELECT 1 FROM inserted WHERE Valor_Total IS NULL OR Valor_Total <= 0)
	BEGIN
		RAISERROR('Valor total deve ser maior que zero', 16, 1)
		ROLLBACK
		RETURN
	END
	
	-- Insere as parcelas, calculando cada data de vencimento como um dia útil
	INSERT INTO Contas_A_Receber (ID_Venda, Num_Parcela, Data_Vencimento, Valor_Parcela, Data_Pagamento)
	SELECT
		i.ID_Venda,
		NumParcela,
		dbo.fn_ProximoDiaUtil(DATEADD(MONTH, NumParcela - 1, i.Data_Venda)), -- Próximo dia útil
		i.Valor_Total / i.Numero_Parcelas, -- Valor de cada parcela
		NULL
	FROM inserted i
	CROSS JOIN (
		SELECT 1 as NumParcela UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
		SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL
		SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
	) NumParcelas
	WHERE NumParcela <= i.Numero_Parcelas
END
GO

-- SEÇÃO 17: TESTES - CONSULTAR DADOS
-- Exibe estado inicial das tabelas antes das operações

-- 1. consultar o estado inicial das tabelas
SELECT * FROM Produto;
SELECT * FROM Saldo;
SELECT * FROM Feriados_Fixos;
SELECT * FROM Feriados_Do_Ano;

-- SEÇÃO 18: TESTE - INSERIR VENDA
-- Insere uma venda de teste no feriado de 01/05/2026
-- Produto 17: PlayStation 5, Quantidade: 3, Valor: 14999.97, 3 parcelas

-- 2. simular a inserção de uma venda (Venda teste no feriado de 01/05/2026)
INSERT INTO Venda (Data_Venda, ID_Cliente, ID_Produto, QTD_Venda, Valor_Total, Numero_Parcelas)
VALUES ('2026-05-01', 99, 1, 3, 14999.97, 3);

-- SEÇÃO 19: TESTE - VERIFICAR SALDO APÓS VENDA
-- O saldo deve ser 97 (100 inicial - 3 vendidos)

-- 3. verificar o impacto no saldo do produto vendido
SELECT * FROM Saldo WHERE ID_Produto = 1;

-- SEÇÃO 20: TESTE - VERIFICAR PARCELAS
-- Exibe as 3 parcelas geradas, com datas ajustadas para dias úteis

-- 4. verificar o parcelamento gerado no Contas a Receber
SELECT * FROM Contas_A_Receber;
