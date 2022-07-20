clear all
set more off
capture log close

******
* 1. Establecer carpetas de trabajo
******

global o1 "C:/Users/Diego/OneDrive/Escritorio/IDIC 2022/"

global o2 "$o1/1 Bases de Datos/"

global o3 "$o1/2 Resultados/"

global sectores_lista 1 "AGRI.HUNT" 2 "FISH.AQUA" 3 "MINI.HIDR" 4 "MINI.META" 5 "MINI.SUPP" 6 "FOOD.PROD" 7 "TEXT.LEAT" 8 "WOOD.PROD" 9 "PAPE.PROD" 10 "OIL.REFIN" 11 "CHEM.PROD" 12 "PHAR.MEDI" 13 "RUBB.PLAS" 14 "OTH.NOMET" 15 "BASI.META" 16 "FABR.META" 17 "COMP.ELEC" 18 "ELEC.EQUI" 19 "MACH.EQUI" 20 "MOTO.VEHI" 21 "OTHE.TRAN" 22 "MANU.NEC" 23 "ELEC.GAS" 24 "WATE.SUPP" 25 "CONSTR" 26 "WHOL.RETA" 27 "LAND.TRAN" 28 "WATE.TRAN" 29 "AIR.TRAN" 30 "WARE.SUPP" 31 "POST.COUR" 32 "ACCO.FOOD" 33 "PUBL.AUDI" 34 "TELE.COMU" 35 "IT.OTHER" 36 "FINA.INSU" 37 "REAL.ESTA" 38 "PROF.SCIE" 39 "ADMI.SUPP" 40 "PUBL.ADMI" 41 "EDUC" 42 "HUMA.HEAL" 43 "ARTS.ENTE" 44 "OTHE.SERV" 45 "ACTI.OF.H"

global paises_lista 1 "AUS" 2 "AUT" 3 "BEL" 4 "CAN" 5 "CHL" 6 "COL" 7 "CRI" 8 "CZE" 9 "DNK" 10 "EST" 11 "FIN" 12 "FRA" 13 "DEU" 14 "GRC" 15 "HUN" 16 "ISL" 17 "IRL" 18 "ISR" 19 "ITA" 20 "JPN" 21 "KOR" 22 "LVA" 23 "LTU" 24 "LUX" 25 "MEX" 26 "NLD" 27 "NZL" 28 "NOR" 29 "POL" 30 "PRT" 31 "SVK" 32 "SVN" 33 "ESP" 34 "SWE" 35 "CHE" 36 "TUR" 37 "GBR" 38 "USA" 39 "ARG" 40 "BRA" 41 "BRN" 42 "BGR" 43 "KHM" 44 "CHN" 45 "HRV" 46 "CYP" 47 "IND" 48 "IDN" 49 "HKG" 50 "KAZ" 51 "LAO" 52 "MYS" 53 "MLT" 54 "MAR" 55 "MMR" 56 "PER" 57 "PHL" 58 "ROU" 59 "RUS" 60 "SAU" 61 "SGP" 62 "ZAF" 63 "TWN" 64 "THA" 65 "TUN" 66 "VNM" 67 "ROW"

/*
local sectores D01T02 D05T06 D07T08 D20 D21 D69T75 D86T88

local posiciones 1 3 4 11 12 38 42

local indicadores DF DVADF FVADF VANDF DIX DFX XB DVAX FVAX DVXX FW BW POS
*/

******
* 2. Cargar Base de Datos
******
forv anio=1995(1)2018{
clear all
set more off
import delimited "$o2/ICIO_BD/ICIO_1995-2018/ICIO2021_`anio'.csv", clear

******
* 2.1. Verificar la no existencia de missing values
******

misstable tree *

******
* 2.2. Agrupar columnas de demanda final por pais
******

*** Separar la base de datos en matrices

mkmat aus_01t02 - total, matrix(ICIO) rownames(v1)

matrix VA = ICIO[3263..3263,1..3598]
matrix X = ICIO[3264..3264,1..3598]
matrix Taxes = ICIO[3196..3262,1..3598]
matrix ID_FD = ICIO[1..3195,1..3598]


******
* 3. Empezar trabajo en MATA
******
mata{

/******
* 3.1. Importar matrices de Stata a Mata
******/
	
ICIO = st_matrix("ICIO")
VA = st_matrix("VA")
X = st_matrix("X")
Taxes = st_matrix("Taxes")
ID_FD = st_matrix("ID_FD")

/* Corrroborar la no existencia de missing */
missing(ICIO)


/******
* 3.2. Agregar China y Mexico (filas)
******/

/*** Agregar China ***/
/* CHN */
CHN_F = ICIO[1936..1980,1..3598]
/* CN1 */
CN1_F = ICIO[3106..3150,1..3598]
/* CN2 */
CN2_F = ICIO[3151..3195,1..3598]

CHN_FC = CHN_F :+ CN1_F :+ CN2_F

ID_FD[1936..1980,1..3598] = CHN_FC

/*** Agregar Mexico */
/* MEX */
MEX_F = ID_FD[1081..1125,1..3598]
/* MX1 */
MX1_F = ID_FD[3016..3060,1..3598]
/* MX2 */
MX2_F = ID_FD[3061..3105,1..3598]

MEX_FC = MEX_F :+ MX1_F :+ MX2_F

ID_FD[1081..1125,1..3598] = MEX_FC

/* Reagrupar las matrices separadas en un inicio*/

ID_FD_N = (ID_FD\ Taxes \ VA \ X)


/******
* 3.3. Agregar China y Mexico (columnas)
******/

/*** Agregar China ***/
/* CHN */
CHN_C = ID_FD_N[1..3264,1936..1980]
/* CN1 */
CN1_C = ID_FD_N[1..3264,3106..3150]
/* CN2 */
CN2_C = ID_FD_N[1..3264,3151..3195]

CHN_CC = CHN_C :+ CN1_C :+ CN2_C

ID_FD_N[1..3264,1936..1980] = CHN_CC

/*** Agregar Mexico ***/
/* MEX */
MEX_C = ID_FD_N[1..3264,1081..1125]
/* MX1 */
MX1_C = ID_FD_N[1..3264,3016..3060]
/* MX2 */
MX2_C = ID_FD_N[1..3264,3061..3105]

MEX_CC = MEX_C :+ MX1_C :+ MX2_C

ID_FD_N[1..3264,1081..1125] = MEX_CC


/*** Corroborar suma de la demanda intermedia ***/

/* SUMA ID: sum(ID_FD_N[1..3015,1..3015]) */


/******
* 3.4. Volver a separar matrices ID_FD_N_F_C(3354x3353)
******/

/*** Separar la matriz ID_FD_N en dos, sin contar columnas Mexico y China 1 y 2 ***/
ICIO_1C = ID_FD_N[1..3264,1..3015]

ICIO_2C = ID_FD_N[1..3264,3196..3598]

ICIO_NC = (ICIO_1C, ICIO_2C)


/*** Separar la matriz ICIO_NC en dos, sin contar filas Mexico y China 1 y 2 ***/
ICIO_1F = ICIO_NC[1..3015,1..3418]

ICIO_2F = ICIO_NC[3196..3264,1..3418]


ICIO_NCF = (ICIO_1F \ ICIO_2F)

/*** Separar ICIO_NCF en ID, VA, X, FD (Base final)***/
ID_N = ICIO_NCF[1..3015,1..3015]
TAXES_N = ICIO_NCF[3016..3082,1..3015]
VA_N = ICIO_NCF[3083..3083,1..3015]
X_N = ICIO_NCF[3084..3084,1..3015]
FD_N = ICIO_NCF[1..3015,3016..3417]

/******
* 3.5. Generar matriz VAB (suma de la matriz Impuestos y Subsidios con la matriz VA)
******/
/*
ncolsVA_N = cols(VA_N)
VAB = J(1,ncolsVA_N,0)
for (j=1;j<=ncolsVA_N;j++) {

VAB[1,j] = sum(TAXES_N[.,j]) :+ VA_N[1,j] 
}

*/

VAB = colsum(TAXES_N) :+ VA_N

/******
* 3.6. Cálculos
******/

/*** Leontief ***/
A = ID_N:/X_N

A = editmissing(A, 0)

nrows= rows(ID_N)
ncols= cols(ID_N)
Eye = I(rows(ID_N))  
/*B = qrinv(Eye-A)*/
/*B = pinv(Eye-A)*/
B = pinv(Eye-A)
/*B = invsym(Eye-A)*/
}

mata: B_`anio' = B
mata: mata matsave "$o3/Matriz_B/B_`anio'" B_`anio', replace
}


forv anio=1995(1)2018{
clear all
set more off

mata: mata matuse "$o3/Matriz_B/B_`anio'", replace
mata: B = B_`anio'

import delimited "$o2/ICIO_BD/ICIO_1995-2018/ICIO2021_`anio'.csv", clear


******
* 2.2. Agrupar columnas de demanda final por pais
******

*** Separar la base de datos en matrices

mkmat aus_01t02 - total, matrix(ICIO) rownames(v1)

matrix VA = ICIO[3263..3263,1..3598]
matrix X = ICIO[3264..3264,1..3598]
matrix Taxes = ICIO[3196..3262,1..3598]
matrix ID_FD = ICIO[1..3195,1..3598]


******
* 3. Empezar trabajo en MATA
******
mata{

/******
* 3.1. Importar matrices de Stata a Mata
******/
	
ICIO = st_matrix("ICIO")
VA = st_matrix("VA")
X = st_matrix("X")
Taxes = st_matrix("Taxes")
ID_FD = st_matrix("ID_FD")

/* Corrroborar la no existencia de missing */
missing(ICIO)


/******
* 3.2. Agregar China y Mexico (filas)
******/

/*** Agregar China ***/
/* CHN */
CHN_F = ICIO[1936..1980,1..3598]
/* CN1 */
CN1_F = ICIO[3106..3150,1..3598]
/* CN2 */
CN2_F = ICIO[3151..3195,1..3598]

CHN_FC = CHN_F :+ CN1_F :+ CN2_F

ID_FD[1936..1980,1..3598] = CHN_FC

/*** Agregar Mexico */
/* MEX */
MEX_F = ID_FD[1081..1125,1..3598]
/* MX1 */
MX1_F = ID_FD[3016..3060,1..3598]
/* MX2 */
MX2_F = ID_FD[3061..3105,1..3598]

MEX_FC = MEX_F :+ MX1_F :+ MX2_F

ID_FD[1081..1125,1..3598] = MEX_FC

/* Reagrupar las matrices separadas en un inicio*/

ID_FD_N = (ID_FD\ Taxes \ VA \ X)


/******
* 3.3. Agregar China y Mexico (columnas)
******/

/*** Agregar China ***/
/* CHN */
CHN_C = ID_FD_N[1..3264,1936..1980]
/* CN1 */
CN1_C = ID_FD_N[1..3264,3106..3150]
/* CN2 */
CN2_C = ID_FD_N[1..3264,3151..3195]

CHN_CC = CHN_C :+ CN1_C :+ CN2_C

ID_FD_N[1..3264,1936..1980] = CHN_CC

/*** Agregar Mexico ***/
/* MEX */
MEX_C = ID_FD_N[1..3264,1081..1125]
/* MX1 */
MX1_C = ID_FD_N[1..3264,3016..3060]
/* MX2 */
MX2_C = ID_FD_N[1..3264,3061..3105]

MEX_CC = MEX_C :+ MX1_C :+ MX2_C

ID_FD_N[1..3264,1081..1125] = MEX_CC


/*** Corroborar suma de la demanda intermedia ***/

/* SUMA ID: sum(ID_FD_N[1..3015,1..3015]) */


/******
* 3.4. Volver a separar matrices ID_FD_N_F_C(3354x3353)
******/

/*** Separar la matriz ID_FD_N en dos, sin contar columnas Mexico y China 1 y 2 ***/
ICIO_1C = ID_FD_N[1..3264,1..3015]

ICIO_2C = ID_FD_N[1..3264,3196..3598]

ICIO_NC = (ICIO_1C, ICIO_2C)


/*** Separar la matriz ICIO_NC en dos, sin contar filas Mexico y China 1 y 2 ***/
ICIO_1F = ICIO_NC[1..3015,1..3418]

ICIO_2F = ICIO_NC[3196..3264,1..3418]


ICIO_NCF = (ICIO_1F \ ICIO_2F)

/*** Separar ICIO_NCF en ID, VA, X, FD (Base final)***/
ID_N = ICIO_NCF[1..3015,1..3015]
TAXES_N = ICIO_NCF[3016..3082,1..3015]
VA_N = ICIO_NCF[3083..3083,1..3015]
X_N = ICIO_NCF[3084..3084,1..3015]
FD_N = ICIO_NCF[1..3015,3016..3417]

/******
* 3.5. Generar matriz VAB (suma de la matriz Impuestos y Subsidios con la matriz VA)
******/
/*
ncolsVA_N = cols(VA_N)
VAB = J(1,ncolsVA_N,0)
for (j=1;j<=ncolsVA_N;j++) {

VAB[1,j] = sum(TAXES_N[.,j]) :+ VA_N[1,j] 
}

*/

VAB = colsum(TAXES_N) :+ VA_N

/******
* 3.6. Cálculos
******/

/*** Leontief ***/
A = ID_N:/X_N

A = editmissing(A, 0)
/*nrows= rows(ID_N)
ncols= cols(ID_N)
Eye = I(rows(ID_N))  
/*B = qrinv(Eye-A)*/
/*B = pinv(Eye-A)*/
/*B = pinv(Eye-A)*/
/*B = invsym(Eye-A)*/
*/


/*** Vhat (G) ***/
G = VAB:/X_N
G = editmissing(G, 0)

/*** Generar primera multplicación ***/ 
TV_1 = diag(G)*B

/*** Generar segunda multplicación ***/ 
/*
FD = J(3015,1,0)
for (i=1;i<=3015;i++){
	FD[i,.] = sum(FD_N[i,.])
}
*/

FD = rowsum(FD_N)
TV = TV_1*diag(FD)

/*
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
*/
/*
/******
* 3.7. Generar vector de Comprobacion
******/

/*0. Generar vector de 0s en donde se guardarán los parametros de los siguientes puntos */
MC = J(1,4,0)

/*1. Comprobar: la matriz ID con arreglos sea igual a la matriz ID original */
MC[1,1] = round(sum(ID_N)) == round(sum(ICIO[1..3195,1..3195]))
 
/*2. Comprobar: la suma de cada columna de Tv1 sea igual a 1 */
MC2 = J(1,3015,0)

for (j=1;j<=3015;j++){
	MC2[.,j] = round(sum(TV_1[.,j])) == 1
}

MC[1,2] = sum(MC2)

/*2.1. Generar: vector de las posiciones con valores 0s del vector MC2 */
v = J(1,22,0)
res1 = J(1, 22, .)
for(i=1; i<=22; i++){
        minindex(MC2, 22, v, .)
        res1[., i] = v[i, .]
}
    

/*3. Comprobar: suma vertical de ID y FD sea igual a Output; y suma horizontal de ID y VAB sea igual a Output */
MC3 = J(2,3015,0)
for (j=1;j<=3015;j++){
	MC3[1,j] = round(sum(ID_N[.,j]) + sum(VAB[.,j])) == round(X_N[.,j])
	if (MC3[1,j]==0) MC3[1,j] = round(sum(ID_N[.,j]) + sum(VAB[.,j]),0.5) == round(X_N[.,j],0.5)
	MC3[2,j] = round(sum(ID_N[j,.]) + sum(FD_N[j,.])) == round(X_N[.,j])
	if (MC3[2,j]==0) MC3[2,j] = round(sum(ID_N[j,.]) + sum(FD_N[j,.]),0.5) == round(X_N[.,j],0.5)
}

MC[1,3] = sum(MC3)

/*3.1. Generar: vector de las posiciones con valores 0s del vector MC3 */
b = J(1,22,0)
res2 = J(1, 4, .)
for(i=1; i<=4; i++){
        minindex(MC3[2,.], 4, b, .)
        res2[., i] = b[i, .]
}

/*4. Comprobar: suma de cada columna de la matriz Tiva sea igual al valor respectivo de la demanda final (FD) */	
MC4 = J(1,3015,0)

for (i=1;i<=3015;i++){
	MC4[.,i] = round(sum(TV[.,i])) == round(FD[i,.])
	if (MC4[.,i]==0) MC4[.,i] = round(sum(TV[.,i]),0.5) == round(FD[i,.],0.5)
	}

MC[1,4] = sum(MC4)

/*4.1. Generar: vector de las posiciones con valores 0s del vector MC4 */
f = J(1,22,0)
res3 = J(1, 4, .)
for(i=1; i<=4; i++){
        minindex(MC4, 4, f, .)
        res3[., i] = f[i, .]
}

/*5. Guardar las posiciones con valores 0s del vector MC2, MC3 y MC4 */
MC_ = J(3,25,0)

MC_[1,1..22] = res1
MC_[2,1..4] = res2
MC_[3,1..4] = res3
*/

/******
* 3.8. Descomposición de la DF
******/
Diag = J(45, 45, 1)

for(i=1; i<=66; i++){
		if (i==1) I = blockdiag(Diag, Diag)
		else I = blockdiag(I, Diag)
}

DVADF_1 = TV :* I

DVADF = colsum(DVADF_1)

FVADF_1 = TV :- DVADF_1

FVADF = colsum(FVADF_1)

VANDF = DVADF :/ FD'

/* Comprobacion */

GA = DVADF :+ FVADF
/*
round(sum(GA)) == round(sum(FD'))
*/

MC5 = J(1,3015,0)

for (i=1;i<=3015;i++){
	MC5[.,i] = round((GA[.,i])) == round(sum(FD'[.,i]))
	if (MC5[.,i]==0) MC5[.,i] = round((GA[.,i]), 0.5) == round(sum(FD'[.,i]), 0.5)
	}

MCX = J(1,3,0)

MCX[1,1] = sum(MC5)

/******
* 3.9. Descomposición de la Xs
******/

/******
* 3.9.1. Generación de TVX
******/

J = J(3015,3015,1)

IX = J :- I 

DIX_1 = ID_N :* IX

DIX = rowsum(DIX_1)

Diag = J(45, 6, 1)

for(i=1; i<=66; i++){
		if (i==1) I = blockdiag(Diag, Diag)
		else I = blockdiag(I, Diag)
}

J = J(3015, 402, 1)

FX = J :- I

DFX_1 = FD_N :* FX

DFX = rowsum(DFX_1)

XB = DIX :+ DFX

/* Nota: añadir prueba */

TVX = diag(G)*B*diag(XB)

/* Comprobacion */
/*
round(sum(TVX)) == round(sum(XB'))
*/

MC6 = J(1,3015,0)

for (i=1;i<=3015;i++){
	MC6[.,i] = round(sum(TVX[.,i])) == round(sum(XB'[.,i]))
	if (MC6[.,i]==0) MC6[.,i] = round(sum(TVX[.,i]), 0.5) == round(sum(XB'[.,i]), 0.5)
	}

MCX[1,2] = sum(MC6)

/******
* 3.9.2. Descomponer TVX
******/

Diag = J(45, 45, 1)

for(i=1; i<=66; i++){
		if (i==1) I = blockdiag(Diag, Diag)
		else I = blockdiag(I, Diag)
}

DVAX_1 = TVX :* I

DVAX = colsum(DVAX_1)

FVAX_1 = TVX :- DVAX_1

FVAX = colsum(FVAX_1)

/* Comprobacion */

GA = DVAX :+ FVAX

/*
round(sum(GA)) == round(sum(XB'))
*/

MC7 = J(1,3015,0)

for (i=1;i<=3015;i++){
	MC7[.,i] = round((GA[.,i])) == round(sum(XB'[.,i]))
	if (MC7[.,i]==0) MC7[.,i] = round((GA[.,i]), 0.5) == round(sum(XB'[.,i]), 0.5)
	}

MCX[1,3] = sum(MC7)

DVXX = rowsum(FVAX_1)

/******
* 3.9.3. Participaciones
******/

/* Nota: hacer seguimiento a los 0s*/
FW = DVXX :/ XB 

BW = FVAX :/ XB'

FW = editmissing(FW,0)
BW = editmissing(BW,0)

POS = ln(1 :+ FW') :- ln(1 :+ BW)

missing(POS)

/******
* 3.9.4. Preparar vectores para el punto 4.
******/
DIX = DIX'
DFX = DFX'
XB = XB'
DVXX = DVXX'
FW = FW'
FD = FD'
VBP = X_N
VADF_N = TV
VADF = rowsum(TV)'
ID_V = rowsum(ID_N)'
ID_C = colsum(ID_N)
}
/******
* 4. Elaborar Dataset panel
******/

/******
* 4.1. Juntar DVAX de cada país anual, por sector
******/

foreach indicador in FD DVADF FVADF VANDF VADF DIX DFX XB DVAX FVAX DVXX FW BW POS VBP ID_V ID_C{
forv posicion = 1(1)45{
mata{
`indicador'_ = J(1,67,.)
i=`posicion'
for (j=1; j<=67; j++){
	`indicador'_[1,j..j] = `indicador'[1,i..i]
	i=i+45
}

dataset_`indicador' = `indicador'_'

dataset_`indicador'_`posicion'_`anio' = (dataset_`indicador')
}
mata: mata matsave "$o3/`anio'/dataset_`indicador'_`posicion'_`anio'" dataset_`indicador'_`posicion'_`anio', replace

if `anio' == 1995 {
/*agregar matriz "Total" para 1995*/

mata: dataset_`indicador'_`posicion'_total = dataset_`indicador'_`posicion'_`anio'
mata: mata matsave "$o3/Total/dataset_`indicador'_`posicion'_total" dataset_`indicador'_`posicion'_total, replace
}

if `anio' != 1995 {

mata: mata matuse "$o3/Total/dataset_`indicador'_`posicion'_total", replace
mata: dataset_`indicador'_`posicion'_total = (dataset_`indicador'_`posicion'_total, dataset_`indicador'_`posicion'_`anio')
mata: mata matsave "$o3/Total/dataset_`indicador'_`posicion'_total" dataset_`indicador'_`posicion'_total, replace
}
}
}

foreach indicador in ID_N FD FD_N VAB VBP VADF_N TVX{

if `anio' == 1995 {

mata: `indicador'_suma = `indicador'
mata: mata matsave "$o3/2 Suma/`indicador'_suma" `indicador'_suma, replace
}

if `anio' != 1995 {
mata: mata matuse "$o3/2 Suma/`indicador'_suma", replace
mata: `indicador'_suma = `indicador'_suma :+ `indicador'
mata: mata matsave "$o3/2 Suma/`indicador'_suma" `indicador'_suma, replace
}
}
}

/******
* 4.1.1 Juntar datos de cada sector en matrices y vectores
******/


/* Loop para vectores fila */
foreach indicador in VAB VBP FD{
clear all
mata: mata matuse "$o3/2 Suma/`indicador'_suma", replace

mata: `indicador'_suma_sectores = J(1,45,1)

mata: s = J(1,1,1..45)'

forv i=1(1)45{
mata{

`indicador'_suma_`i'  = J(1,67,1)

k=`i'
for (j=1; j<=67; j++){

`indicador'_suma_`i'[1,j..j] = `indicador'_suma[1,k..k]

k=k+45
}

`indicador'_suma_sectores[1,`i'..`i'] = sum(`indicador'_suma_`i')

}
}

mata: `indicador'_suma_sectores = (s,`indicador'_suma_sectores')
mata: st_matrix("`indicador'_suma_sectores", `indicador'_suma_sectores)
svmat `indicador'_suma_sectores, names(col)

label define sectores_lista $sectores_lista, replace
label values c1 sectores_lista

export excel "$o3/2 Suma/Suma sectores/`indicador'_suma_sectores.xlsx", firstrow(variables) replace
}

/* Loop para matrices */
foreach indicador in ID_N{
clear all
mata: s = J(1,1,1..45)'
mata: mata matuse "$o3/2 Suma/`indicador'_suma", replace
mata: `indicador'_suma_sectores_1 = J(3015,45,1)
mata: `indicador'_suma_sectores_2 = J(45,45,1)

forv i=1(1)45{
mata{

`indicador'_suma_`i'  = J(3015,67,1)

k=`i'
for (j=1; j<=67; j++){

`indicador'_suma_`i'[.,j..j] = `indicador'_suma[.,k..k]

k=k+45
}

`indicador'_suma_sectores_1[.,`i'..`i'] = rowsum(`indicador'_suma_`i')

}
}

forv i=1(1)45{
mata{

`indicador'_suma_`i'  = J(67,45,1)

k=`i'
for (j=1; j<=67; j++){

`indicador'_suma_`i'[j..j,.] = `indicador'_suma_sectores_1[k..k,.]

k=k+45
}

`indicador'_suma_sectores_2[`i'..`i',.] = colsum(`indicador'_suma_`i')

}
}
mata: `indicador'_suma_sectores = (s,`indicador'_suma_sectores_2)
mata: st_matrix("`indicador'_suma_sectores", `indicador'_suma_sectores)
svmat `indicador'_suma_sectores, names(col)

label define sectores_lista $sectores_lista, replace
label values c1 sectores_lista

export excel "$o3/2 Suma/Suma sectores/`indicador'_suma_sectores.xlsx", firstrow(variables) replace
}

/******
* 4.2. Elaborar Formato Dataset panel, por sector
******/

/******
* 4.2.1 Elaborar Formato Dataset panel, por sector - 1 (anio pais variable)
******/
foreach indicador in FD DVADF FVADF VANDF DIX DFX XB DVAX FVAX DVXX FW BW POS ID_V ID_C{
clear all
set more off
forv posicion = 1(1)45{
mata: mata matuse "$o3/Total/dataset_`indicador'_`posicion'_total", replace

mata{
anios = (1995..2018)'

a = J(67,1,anios)

nrows =rows(anios)
b = J(nrows*67,1,.)

k=0
for (i=1; i<=67; i++){
paises = J(1,1,i)

for (j=k+1; j<=k+nrows; j++){

b[j..j,1] = paises[.,1]
}
k=k+nrows
}

dataset_panel = (a,b)


ncols = cols(dataset_`indicador'_`posicion'_total)
c = J(ncols*67,1,.)
k=1
j=1
m=nrows
for (i=k; i<=67; i++){

c[k..m,1] = dataset_`indicador'_`posicion'_total[j, 1..ncols]'


k=k+ncols
j=j+1
m=m+ncols
}

dataset_panel = (a,b,c)
}
mata: dataset_panel_`indicador'_`posicion' = dataset_panel
mata: mata matsave "$o3/1 Panel/dataset_panel_`indicador'_`posicion'" dataset_panel_`indicador'_`posicion', replace
}


}

/******
* 4.2.2 Elaborar Formato Dataset panel, por sector - 2 (anio pais sector variable)
******/
clear all
set more off

foreach indicador in VADF XB ID_V FD VBP{
forv posicion = 1(1)45{

mata: mata matuse "$o3/Total/dataset_`indicador'_`posicion'_total", replace

mata: anios = (1995..2018)'
mata: nrows =rows(anios)
mata: sectores = 45

if `posicion'== 1 mata: v=1
else mata: v=v+ncols

if `posicion'== 1 mata: d = J(nrows*67*sectores,1,.)

if `posicion'== 1 mata: m=nrows
else mata: m=m+ncols

mata{

/* Crear vector de años */
a = J(67*sectores,1,anios)

/* Crear vector de paises */
b = J(sectores*67*nrows,1,.)

k=0
for (i=1; i<=67; i++){
paises = J(1,1,i)

for (j=k+1; j<=k+(nrows*sectores); j++){

b[j..j,1] = paises[.,1]

}
k=k + nrows*sectores
}

/* Crear vector de sectores */
j=0
c = J(nrows*sectores,1,.)
for (i=1; i<=sectores; i++){

c[j+1..j+nrows,1] = J(nrows,1,i)

j=j+nrows
}

c = J(67,1,c)

/* Crear vector con datos de cada indicador */

h=v
l=m
ncols = cols(dataset_`indicador'_`posicion'_total)

for (i=1; i<=67; i++){

d[h..l,1] = dataset_`indicador'_`posicion'_total[i, 1..ncols]'


h=h + ncols*sectores
l=l + ncols*sectores
}

dataset_panel = (a,b,c,d)

}
}
mata: dataset_panel_`indicador' = dataset_panel
mata: mata matsave "$o3/1 Panel 2/dataset_panel_`indicador'" dataset_panel_`indicador', replace

}


/******
* 4.3. Agrupar Dataset panel (Stata) y exportar en formato excel
******/

/******
* 4.3.1 Agrupar Dataset panel - 1 (anio pais variable)
******/
clear all
set more off

	mata: mata matuse "$o3/1 Panel/dataset_panel_FD_1", replace
	mata: st_matrix("dataset_panel_FD_1", dataset_panel_FD_1)
	matname dataset_panel_FD_1 anio pais FD_1, columns(1..3) explicit
	matrix dataset_panel_FD_1 = dataset_panel_FD_1[.,1..2]
	svmat dataset_panel_FD_1, names(col)
	
foreach indicador in FD DVADF FVADF VANDF DIX DFX XB DVAX FVAX DVXX FW BW POS ID_V ID_C{
forv posicion = 1(1)45{

	mata: mata matuse "$o3/1 Panel/dataset_panel_`indicador'_`posicion'", replace
	mata: st_matrix("dataset_panel_`indicador'_`posicion'", dataset_panel_`indicador'_`posicion')
	matname dataset_panel_`indicador'_`posicion' anio pais `indicador'_`posicion', columns(1..3) explicit
	matrix dataset_panel_`indicador'_`posicion' = dataset_panel_`indicador'_`posicion'[.,3..3]
	svmat dataset_panel_`indicador'_`posicion', names(col)

}

}

/* Cambiar el nombre de las variables asignándoles su respectivo código CIIU */

local k=1
foreach sector in "AGRI_HUNT" "FISH_AQUA" "MINI_HIDR" "MINI_META" "MINI_SUPP" "FOOD_PROD" "TEXT_LEAT" "WOOD_PROD" "PAPE_PROD" "OIL_REFIN" "CHEM_PROD" "PHAR_MEDI" "RUBB_PLAS" "OTH_NOMET" "BASI_META" "FABR_META" "COMP_ELEC" "ELEC_EQUI" "MACH_EQUI" "MOTO_VEHI" "OTHE_TRAN" "MANU_NEC" "ELEC_GAS" "WATE_SUPP" "CONSTR" "WHOL_RETA" "LAND_TRAN" "WATE_TRAN" "AIR_TRAN" "WARE_SUPP" "POST_COUR" "ACCO_FOOD" "PUBL_AUDI" "TELE_COMU" "IT_OTHER" "FINA_INSU" "REAL_ESTA" "PROF_SCIE" "ADMI_SUPP" "PUBL_ADMI" "EDUC" "HUMA_HEAL" "ARTS_ENTE" "OTHE_SERV" "ACTI_OF_H"{

rename *_`k' *_`sector'

local k =`k'+1
}


/*
rename *_1 *_D01T02 
rename *_3 *_D05T06
rename *_4 *_D07T08
rename *_11 *_D20
rename *_12 *_D21
rename *_38 *_D69T75
rename *_42 *_D86T88
*/


/* Colocar labels a los países */
label define paises_lista $paises_lista, replace
 
label values pais paises_lista

export excel "$o1/2 Resultados/Dataset_1.xlsx", firstrow(variables) replace

save "$o1/2 Resultados/Dataset_1", replace

/******
* 4.3.2 Agrupar Dataset panel - 2 (anio pais sector variable)
******/

clear all
set more off

local k = 36180
local m = 1

forv i=1(1)2{

clear all

	mata: mata matuse "$o3/1 Panel 2/dataset_panel_FD", replace
	mata: dataset_panel_FD_`i' =  dataset_panel_FD[`m'..`k',.]
	mata: st_matrix(" dataset_panel_FD_`i'",  dataset_panel_FD_`i')
	matname  dataset_panel_FD_`i' anio pais sector FD, columns(1..4) explicit
	matrix  dataset_panel_FD_`i' =  dataset_panel_FD_`i'[.,1..3]
	svmat  dataset_panel_FD_`i', names(col)
	
foreach indicador in VADF XB ID_V FD VBP{

	mata: mata matuse "$o3/1 Panel 2/dataset_panel_`indicador'", replace
	mata: dataset_panel_`indicador'_`i' =  dataset_panel_`indicador'[`m'..`k',.]
	mata: st_matrix("dataset_panel_`indicador'_`i'", dataset_panel_`indicador'_`i')
	matname dataset_panel_`indicador'_`i' anio pais sector `indicador', columns(1..4) explicit
	matrix dataset_panel_`indicador'_`i' = dataset_panel_`indicador'_`i'[.,4..4]
	svmat dataset_panel_`indicador'_`i', names(col)

	
}
local k = `k' + 36180
local m = `m' + 36180
/* Colocar labels a los sectores */
label define sectores_lista $sectores_lista, replace

label values sector sectores_lista

/* Colocar labels a los países */
label define paises_lista $paises_lista, replace
 
label values pais paises_lista

export excel "$o1/2 Resultados/Dataset_2_`i'.xlsx", firstrow(variables) replace

save "$o1/2 Resultados/Dataset_2_`i'", replace

}

/* Unir las dos partes */
use "$o1/2 Resultados/Dataset_2_1", clear
append using "$o1/2 Resultados/Dataset_2_2"

/* Exportar el dataset unido */
export excel "$o1/2 Resultados/Dataset_2.xlsx", firstrow(variables) replace
save "$o1/2 Resultados/Dataset_2", replace
