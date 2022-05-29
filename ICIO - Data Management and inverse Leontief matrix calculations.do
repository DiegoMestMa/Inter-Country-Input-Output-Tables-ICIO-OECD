clear all
set more off
capture log close

******
* 1. Carpetas de trabajo
******

global o1 "C:/Users/Diego/OneDrive/Escritorio/IDIC 2022/"

global o2 "$o1/1 Bases de Datos/"

global o3 "$o1/2 Resultados/"
******
* 2. Cargar BD
******
forv i=1995(1)1999{
clear all
set more off
import delimited "$o2/ICIO_1995-1999/ICIO2021_`i'.csv", clear

******
* 2.1. Verificar la no existencia de missing values
******

*** 1.
misstable tree *

******
* 2.2. Agrupar columnas de demanda final por pais
******

*** Asignar un número del 1 al 402 a cada columna de demanda final ("unab" agrupa todas las columnas en una lista)
unab myvars : aus_hfce - row_dpabr
tokenize `myvars' 

*** Sumar cada grupo de seis demandas por país y guardar el resultado en la nueva variable "`country'_final" (se eliminan las 6 demandas por pais)
forval j = 1(6)402{ 	
	local country = substr("``j''", 1, 3)
	
	local a hfce
	local b npish
	local c ggfc
	local d gfcf
	local e invnt
	local f dpabr
	
	egen `country'_final = rowtotal(`country'_`a' `country'_`b' `country'_`c' `country'_`d' `country'_`e' `country'_`f')
	
	drop `country'_`a' `country'_`b' `country'_`c' `country'_`d' `country'_`e' `country'_`f' ``j''
}

order total, last

*** Separar la base de datos en matrices

mkmat aus_01t02 - total, matrix(ICIO) rownames(v1)

matrix VA = ICIO[3263..3263,1..3263]
matrix X = ICIO[3264..3264,1..3263]
matrix Taxes = ICIO[3196..3262,1..3263]
matrix ID_FD = ICIO[1..3195,1..3263]


******
* 3. Empezar trabajo en MATA
******
	mata {

ICIO = st_matrix("ICIO")
VA = st_matrix("VA")
X = st_matrix("X")
Taxes = st_matrix("Taxes")
ID_FD = st_matrix("ID_FD")



missing(ICIO)

/******
* 3.1. Agregar China y Mexico (filas)
******/

/*** Agregar China ***/
// CHN
CHN_F = ICIO[1936..1980,1..3263]
// CN1
CN1_F = ICIO[3106..3150,1..3263]
// CN2
CN2_F = ICIO[3151..3195,1..3263]

CHN_FC = CHN_F :+ CN1_F :+ CN2_F

ID_FD[1936..1980,1..3263] = CHN_FC

/*** Agregar Mexico */
// MEX
MEX_F = ID_FD[1081..1125,1..3263]
// MX1
MX1_F = ID_FD[3016..3060,1..3263]
// MX2
MX2_F = ID_FD[3061..3105,1..3263]

MEX_FC = MEX_F :+ MX1_F :+ MX2_F

ID_FD[1081..1125,1..3263] = MEX_FC

/* Reagrupar las matrices separadas en un inicio*/

ID_FD_N = (ID_FD\ Taxes \ VA \ X)


/******
* 3.2. Agregar China y Mexico (columnas)
******/

/*** Agregar China ***/
// CHN
CHN_C = ID_FD_N[1..3264,1936..1980]
// CN1
CN1_C = ID_FD_N[1..3264,3106..3150]
// CN2
CN2_C = ID_FD_N[1..3264,3151..3195]

CHN_CC = CHN_C :+ CN1_C :+ CN2_C

ID_FD_N[1..3264,1936..1980] = CHN_CC

/*** Agregar Mexico ***/
// MEX
MEX_C = ID_FD_N[1..3264,1081..1125]
// MX1
MX1_C = ID_FD_N[1..3264,3016..3060]
// MX2
MX2_C = ID_FD_N[1..3264,3061..3105]

MEX_CC = MEX_C :+ MX1_C :+ MX2_C

ID_FD_N[1..3264,1081..1125] = MEX_CC


/*** Corroborar suma de la demanda intermedia ***/

// SUMA ID: sum(ID_FD_N[1..3015,1..3015])


/******
* 3.3. Volver a separar matrices ID_FD_N_F_C(3354x3353)
******/

/*** Separar la matriz ID_FD_N en dos, sin contar columnas Mexico y China 1 y 2 ***/
ICIO_1C = ID_FD_N[1..3264,1..3015]

ICIO_2C = ID_FD_N[1..3264,3196..3263]

ICIO_NC = (ICIO_1C, ICIO_2C)


/*** Separar la matriz ICIO_NC en dos, sin contar filas Mexico y China 1 y 2 ***/
ICIO_1F = ICIO_NC[1..3015,1..3083]

ICIO_2F = ICIO_NC[3196..3264,1..3083]


ICIO_NCF = (ICIO_1F \ ICIO_2F)

/*** Separar ICIO_NCF en ID, VA, X, FD (Base final)***/
ID_N = ICIO_NCF[1..3015,1..3015]
VA_N = ICIO_NCF[3083..3083,1..3015]
X_N = ICIO_NCF[3084..3084,1..3015]
FD_N = ICIO_NCF[1..3015,3016..3082]

/******
* 3.4. Cálculos
******/

/*** Leontief ***/
A = ID_N:/X_N

A = editmissing(A, 0)

nrows= rows(ID_N)
ncols= cols(ID_N)
Eye = I(rows(ID_N))  
//B = qrinv(Eye-A)
//B = pinv(Eye-A)
B = pinv(Eye-A)
//B = invsym(Eye-A)

B[1..10,1..10]
missing(B)


/*** Vhat (G) ***/
G = VA_N:/X_N
G = editmissing(G, 0)

/*** Generar primera multplicación ***/ 
Tv1 = diag(G)*B

/*** Generar segunda multplicación ***/ 
n = rows(Tv1)
Tv = J(n,n,0)
FD_N = FD_N'

k=1

for (j=1;j<=67;j++){
for (i=k;i<=k+44;i++){
	Tv[i,.] = Tv1[i,.] :* FD_N[j,.]
}
k=i
}


/******
* 4. Subir la matriz final a Stata y exportar a Excel
******/
st_matrix("B", B)
st_matrix("Tv1", Tv1)
st_matrix("Tv", Tv)


	}


putexcel set "$o3/`i'/Matriz_Tv.xlsx"
putexcel A1 = matrix(Tv)
}

