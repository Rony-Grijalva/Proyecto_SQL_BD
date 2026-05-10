USE Proyecto_Churn_SQL;
GO

/* =========================================================
   CONSULTA GENERAL DEL MODELO RELACIONAL
   Visualización consolidada de clientes, servicios y facturación
========================================================= */

SELECT 
    C.*, 
    S.Subscription_Type, 
    S.Contract_Length, 
    S.Operador, 
    S.Support_Calls,
    F.Total_Spend, 
    F.Payment_Delay, 
    F.Tenure, 
    F.Churn
FROM Clientes C
JOIN Servicios S ON C.CustomerID = S.CustomerID
JOIN Facturacion F ON C.CustomerID = F.CustomerID;


/* =========================================================
   CREACIÓN DE TABLAS
========================================================= */

CREATE TABLE Clientes (
    CustomerID INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(20),
    Region VARCHAR(50)
);

CREATE TABLE Servicios (
    ID_Servicio INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    Subscription_Type VARCHAR(50),
    Contract_Length VARCHAR(50),
    Usage_Frequency INT,
    Support_Calls INT,
    Operador VARCHAR(50),

    FOREIGN KEY (CustomerID) REFERENCES Clientes(CustomerID)
);

CREATE TABLE Facturacion (
    ID_Facturacion INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    Total_Spend DECIMAL(10,2),
    Payment_Delay INT,
    Tenure INT,
    Last_Interaction INT,
    Churn INT,

    FOREIGN KEY (CustomerID) REFERENCES Clientes(CustomerID)
);


/* =========================================================
   VALIDACIÓN DEL DATASET ORIGINAL
========================================================= */

SELECT TOP 10 * 
FROM customer_churn;


/* =========================================================
   INSERCIÓN DE DATOS EN TABLA CLIENTES
========================================================= */

INSERT INTO Clientes (CustomerID, Age, Gender, Region)
SELECT 
    CustomerID,
    Age,
    Gender,
    Region
FROM customer_churn;

SELECT COUNT(*) AS Total_Clientes
FROM Clientes;


/* =========================================================
   INSERCIÓN DE DATOS EN TABLA SERVICIOS
========================================================= */

INSERT INTO Servicios (
    CustomerID,
    Subscription_Type,
    Contract_Length,
    Usage_Frequency,
    Support_Calls,
    Operador
)
SELECT 
    CustomerID,
    Subscription_Type,
    Contract_Length,
    Usage_Frequency,
    Support_Calls,
    Operador
FROM customer_churn;

SELECT COUNT(*) AS Total_Servicios
FROM Servicios;


/* =========================================================
   INSERCIÓN DE DATOS EN TABLA FACTURACION
========================================================= */

INSERT INTO Facturacion (
    CustomerID,
    Total_Spend,
    Payment_Delay,
    Tenure,
    Last_Interaction,
    Churn
)
SELECT 
    CustomerID,
    Total_Spend,
    Payment_Delay,
    Tenure,
    Last_Interaction,
    Churn
FROM customer_churn;

SELECT COUNT(*) AS Total_Facturacion
FROM Facturacion;


/* =========================================================
   VALIDACIÓN DEL MODELO RELACIONAL
========================================================= */

SELECT TOP 10
    C.CustomerID,
    C.Region,
    S.Operador,
    F.Total_Spend,
    F.Churn
FROM Clientes C
JOIN Servicios S ON C.CustomerID = S.CustomerID
JOIN Facturacion F ON C.CustomerID = F.CustomerID;


/* =========================================================
   PREGUNTA 1
   ¿Cuál es la tasa general de churn?
========================================================= */

SELECT 
    COUNT(*) AS Total_Clientes,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS Clientes_Abandonaron,
    ROUND(
        (SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0) / COUNT(*), 
        2
    ) AS Tasa_Churn_Porcentaje
FROM Facturacion;


/* =========================================================
   PREGUNTA 2
   ¿Cómo se distribuyen los clientes por operador?
========================================================= */

SELECT 
    S.Operador,
    COUNT(*) AS Total_Clientes
FROM Servicios S
GROUP BY S.Operador
ORDER BY Total_Clientes DESC;


/* =========================================================
   PREGUNTA 3
   ¿Qué operador tiene la mayor tasa de churn?
========================================================= */

SELECT 
    S.Operador,
    COUNT(*) AS Total_Clientes,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Abandonos,
    ROUND(
        SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Tasa_Churn
FROM Servicios S
JOIN Facturacion F ON S.CustomerID = F.CustomerID
GROUP BY S.Operador
ORDER BY Tasa_Churn DESC;


/* =========================================================
   PREGUNTA 4
   ¿Qué regiones presentan mayor churn?
========================================================= */

SELECT 
    C.Region,
    COUNT(*) AS Total_Clientes,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Abandonos,
    ROUND(
        SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Tasa_Churn
FROM Clientes C
JOIN Facturacion F ON C.CustomerID = F.CustomerID
GROUP BY C.Region
ORDER BY Tasa_Churn DESC;


/* =========================================================
   PREGUNTA 5
   ¿Qué tipo de suscripción presenta mayor churn?
========================================================= */

SELECT 
    S.Subscription_Type,
    COUNT(*) AS Total,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Cancelaciones,
    ROUND(
        SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Tasa_Churn
FROM Servicios S
JOIN Facturacion F ON S.CustomerID = F.CustomerID
GROUP BY S.Subscription_Type
ORDER BY Tasa_Churn DESC;


/* =========================================================
   PREGUNTA 6
   ¿Existe relación entre llamadas a soporte y churn?
========================================================= */

SELECT 
    S.Support_Calls,
    COUNT(*) AS Total,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Abandonos,
    ROUND(
        SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Tasa_Churn
FROM Servicios S
JOIN Facturacion F ON S.CustomerID = F.CustomerID
GROUP BY S.Support_Calls
ORDER BY S.Support_Calls;


/* =========================================================
   PREGUNTA 7
   ¿Cómo impacta el retraso en pagos en el churn?
========================================================= */

SELECT 
    Payment_Delay,
    COUNT(*) AS Total,
    SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS Abandonos,
    ROUND(
        SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 
        2
    ) AS Tasa_Churn
FROM Facturacion
GROUP BY Payment_Delay
ORDER BY Payment_Delay;


/* =========================================================
   PREGUNTA 8
   ¿Qué clientes de alto valor están en riesgo?
========================================================= */

SELECT 
    CustomerID,
    Total_Spend
FROM Facturacion
WHERE Total_Spend > (
    SELECT AVG(Total_Spend) 
    FROM Facturacion
)
AND Churn = 1;


/* =========================================================
   PREGUNTA 9
   ¿Qué combinación de región y operador tiene más churn?
========================================================= */

SELECT 
    C.Region,
    S.Operador,
    COUNT(*) AS Total,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Abandonos
FROM Clientes C
JOIN Servicios S ON C.CustomerID = S.CustomerID
JOIN Facturacion F ON C.CustomerID = F.CustomerID
GROUP BY C.Region, S.Operador
ORDER BY Abandonos DESC;


/* =========================================================
   PREGUNTA 10
   ¿Cómo varía el churn según grupo de edad?
========================================================= */

SELECT 
    CASE 
        WHEN Age < 25 THEN 'Jovenes'
        WHEN Age BETWEEN 25 AND 40 THEN 'Adultos'
        ELSE 'Mayores'
    END AS Grupo_Edad,
    COUNT(*) AS Total,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Abandonos
FROM Clientes C
JOIN Facturacion F ON C.CustomerID = F.CustomerID
GROUP BY 
    CASE 
        WHEN Age < 25 THEN 'Jovenes'
        WHEN Age BETWEEN 25 AND 40 THEN 'Adultos'
        ELSE 'Mayores'
    END;


/* =========================================================
   PREGUNTA 11
   ¿Cómo influye la duración del contrato en el churn?
========================================================= */

SELECT 
    S.Contract_Length,
    COUNT(*) AS Total,
    SUM(CASE WHEN F.Churn = 1 THEN 1 ELSE 0 END) AS Abandonos
FROM Servicios S
JOIN Facturacion F ON S.CustomerID = F.CustomerID
GROUP BY S.Contract_Length;


/* =========================================================
   PREGUNTA 12
   ¿Qué operador retiene clientes por más tiempo?
========================================================= */

SELECT 
    S.Operador,
    AVG(F.Tenure) AS Promedio_Antiguedad
FROM Servicios S
JOIN Facturacion F ON S.CustomerID = F.CustomerID
GROUP BY S.Operador;


/* =========================================================
   PREGUNTA 13
   ¿Cuál es el perfil de cliente con alto riesgo?
========================================================= */

SELECT 
    S.CustomerID,
    S.Support_Calls,
    F.Payment_Delay
FROM Servicios S
JOIN Facturacion F ON S.CustomerID = F.CustomerID
WHERE S.Support_Calls > 5 
  AND F.Payment_Delay > 5;


/* =========================================================
   PREGUNTA 14
   ¿Cuál es la pérdida económica total por churn?
========================================================= */

SELECT 
    SUM(Total_Spend) AS Perdida_Total
FROM Facturacion
WHERE Churn = 1;


/* =========================================================
   PREGUNTA 15
   ¿Cómo priorizar clientes para retención?
========================================================= */

SELECT 
    CustomerID,
    Total_Spend,
    CASE 
        WHEN Total_Spend > 1000 AND Churn = 1 THEN 'ALTA PRIORIDAD'
        WHEN Total_Spend <= 1000 AND Churn = 1 THEN 'MEDIA PRIORIDAD'
        ELSE 'BAJA PRIORIDAD'
    END AS Segmento
FROM Facturacion;