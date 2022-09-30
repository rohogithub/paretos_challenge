--
-- PostgreSQL database dump
--

-- Dumped from database version 14.5
-- Dumped by pg_dump version 14.5

-- Started on 2022-09-29 20:18:04

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 209 (class 1259 OID 16403)
-- Name: cost_toy_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cost_toy_data (
    sku character(10),
    netto_cost real
);


ALTER TABLE public.cost_toy_data OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17015)
-- Name: dim_orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.dim_orders (
    order_date date,
    revenue real,
    total_sku_cost real,
    margin real,
    numberof_orders bigint,
    tax real,
    numberof_invalid_total_price bigint,
    numberof_null_total_sku bigint,
    numberof_negetive_margin bigint,
    sum_negetive_margin real
);


ALTER TABLE public.dim_orders OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 16409)
-- Name: orders_line_items_toy_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_line_items_toy_data (
    sku character(10),
    orders_line_items_price real,
    orders_line_items_quantity bigint,
    _airbyte_orders_hashid character(50)
);


ALTER TABLE public.orders_line_items_toy_data OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16406)
-- Name: orders_toy_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders_toy_data (
    created_at date,
    total_price real,
    total_price_without_tax real,
    _airbyte_orders_hashid character(50)
);


ALTER TABLE public.orders_toy_data OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 16999)
-- Name: stg_SKU_cost; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public."stg_SKU_cost" AS
 WITH cost AS (
         SELECT cost_toy_data.sku,
            cost_toy_data.netto_cost
           FROM public.cost_toy_data
        )
 SELECT cost.sku,
    cost.netto_cost
   FROM cost;


ALTER TABLE public."stg_SKU_cost" OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 17004)
-- Name: stg_orders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.stg_orders AS
 WITH orders AS (
         SELECT orders_toy_data.created_at,
            orders_toy_data.total_price,
            orders_toy_data.total_price_without_tax,
            orders_toy_data._airbyte_orders_hashid
           FROM public.orders_toy_data
        )
 SELECT orders.created_at,
    orders.total_price,
    orders.total_price_without_tax,
    orders._airbyte_orders_hashid
   FROM orders;


ALTER TABLE public.stg_orders OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16998)
-- Name: stg_orders_items; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.stg_orders_items AS
 WITH orders_items AS (
         SELECT orders_line_items_toy_data.sku,
            orders_line_items_toy_data.orders_line_items_price,
            orders_line_items_toy_data.orders_line_items_quantity,
            orders_line_items_toy_data._airbyte_orders_hashid
           FROM public.orders_line_items_toy_data
        )
 SELECT orders_items.sku,
    orders_items.orders_line_items_price,
    orders_items.orders_line_items_quantity,
    orders_items._airbyte_orders_hashid
   FROM orders_items;


ALTER TABLE public.stg_orders_items OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 17010)
-- Name: stg_fact_orders; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.stg_fact_orders AS
 WITH sku_cost AS (
         SELECT "stg_SKU_cost".sku,
            "stg_SKU_cost".netto_cost
           FROM public."stg_SKU_cost"
        ), orders AS (
         SELECT stg_orders.created_at,
            stg_orders.total_price,
            stg_orders.total_price_without_tax,
            stg_orders._airbyte_orders_hashid
           FROM public.stg_orders
        ), orders_items AS (
         SELECT stg_orders_items.sku,
            stg_orders_items.orders_line_items_price,
            stg_orders_items.orders_line_items_quantity,
            stg_orders_items._airbyte_orders_hashid
           FROM public.stg_orders_items
        )
 SELECT orders._airbyte_orders_hashid AS order_id,
    orders.created_at AS order_date,
    orders.total_price,
    orders.total_price_without_tax,
    sum((((orders_items.orders_line_items_quantity)::double precision * sku_cost.netto_cost))::real) AS total_sku_cost,
    sum(orders_items.orders_line_items_price) AS sum_orders_line_items_price,
    (orders.total_price - sum((((orders_items.orders_line_items_quantity)::double precision * sku_cost.netto_cost))::real)) AS margin
   FROM ((orders
     LEFT JOIN orders_items ON ((orders._airbyte_orders_hashid = orders_items._airbyte_orders_hashid)))
     LEFT JOIN sku_cost ON ((orders_items.sku = sku_cost.sku)))
  GROUP BY orders._airbyte_orders_hashid, orders.created_at, orders.total_price, orders.total_price_without_tax;


ALTER TABLE public.stg_fact_orders OWNER TO postgres;

--
-- TOC entry 3334 (class 0 OID 16403)
-- Dependencies: 209
-- Data for Name: cost_toy_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cost_toy_data (sku, netto_cost) FROM stdin;
RH10406   	20.94
RH10405   	20.94
RH10404   	20.94
RH10403   	20.94
RH10402   	20.94
RH10401   	20.94
RH10400   	7.95
RH10399   	7.95
RH10398   	7.95
RH10397   	7.95
RH10396   	7.95
RH10395   	7.95
RH10394   	7.95
RH10383   	18.5
RH10382   	18.5
RH10381   	18.5
RH10380   	18.5
RH10379   	18.5
RH10378   	18.5
RH10377   	18.5
RH10376   	18.5
RH10371   	20.75
RH10370   	20.75
RH10369   	20.75
RH10368   	20.75
RH10367   	20.75
RH10366   	21.5
RH10365   	21.5
RH10364   	21.5
RH10363   	21.5
RH10362   	21.5
RH10361   	21.5
RH10360   	21.5
RH10359   	21.5
RH10358   	21.5
RH10357   	21.5
RH10356   	4.25
RH10355   	4.25
RH10354   	6.05
RH10353   	6.05
RH10352   	6.05
RH10339   	20.94
RH10338   	20.94
RH10337   	20.94
RH10336   	20.94
RH10335   	20.94
RH10334   	20.94
RH10321   	8.82
RH10320   	8.82
RH10319   	8.82
RH10318   	8.82
RH10317   	8.82
RH10316   	8.82
RH10315   	8.5
RH10314   	8.5
RH10313   	8.5
RH10312   	8.5
RH10311   	8.5
RH10310   	8.5
RH10309   	8.5
RH10308   	8.5
RH10307   	8.5
RH10306   	8.5
RH10305   	8.5
RH10303   	8.5
RH10302   	8.5
RH10301   	8.5
RH10300   	8.5
RH10253   	8.05
RH10252   	8.05
RH10251   	8.05
RH10250   	8.05
RH10249   	8.05
RH10248   	8.05
RH10246   	20.94
RH10245   	20.94
RH10244   	20.94
RH10243   	20.94
RH102427  	20.94
RH10242   	20.94
RH10241   	23.32
RH10240   	23.32
RH10239   	23.32
RH10238   	23.32
RH10237   	23.32
RH10236   	23.32
RH10235   	1.51
RH10234   	1.51
RH10233   	1.69
RH10232   	1.69
RH10231   	1.52
RH10230   	1.52
RH10229   	1.43
RH10228   	1.43
RH10227   	4.3
RH10226   	4.3
RH10225   	4.3
RH10224   	4.3
RH10223   	4.3
RH10222   	4.3
RH10221   	4.3
RH10220   	4.3
RH10219   	4.3
RH10218   	4.3
RH10217   	4.3
RH10216   	4.3
RH10215   	4.3
RH10214   	4.3
RH10213   	4.3
RH10212   	20.94
RH10211   	20.94
RH10210   	20.94
RH10209   	20.94
RH10208   	20.94
RH10207   	20.94
RH10206   	20.94
RH10205   	20.94
RH10204   	20.94
RH10203   	20.94
RH10202   	20.94
RH10201   	20.94
RH10200   	20.94
RH10199   	20.94
RH10198   	20.94
RH10197   	20.94
RH10196   	20.94
RH10195   	20.94
RH10194   	21.84
RH10193   	21.84
RH10192   	21.84
RH10191   	21.84
RH10190   	21.84
RH10189   	21.84
RH10188   	21.84
RH10187   	21.84
RH10186   	21.84
RH10185   	21.84
RH10184   	21.84
RH10183   	21.84
RH10182   	21.84
RH10181   	21.84
RH10180   	21.84
RH10179   	21.84
RH10178   	21.84
RH10177   	21.84
RH10176   	21.84
RH10175   	21.84
RH10174   	20.94
RH10173   	20.94
RH10172   	20.94
RH10171   	20.94
RH10170   	20.94
RH10169   	20.94
RH10168   	49.92
RH10167   	49.92
RH10166   	49.92
RH10165   	49.92
RH10164   	49.92
RH10163   	49.92
RH10162   	49.92
RH10161   	49.92
RH10160   	49.92
RH10159   	49.92
RH10158   	49.92
RH10157   	49.92
RH10156   	49.92
RH10155   	49.92
RH10154   	20.94
RH10153   	20.94
RH10152   	20.94
RH10151   	20.94
RH10150   	20.94
RH10149   	20.94
RH10148   	20.94
RH10147   	20.94
RH10146   	20.94
RH10145   	20.94
RH10144   	20.94
RH10143   	20.94
RH10141   	22.55
RH10140   	22.55
RH10139   	22.55
RH10138   	22.55
RH10137   	22.55
RH10134   	22.55
RH10133   	22.55
RH10132   	22.55
RH10131   	22.55
RH10130   	22.55
RH10128   	2.87
RH10127   	2.87
RH10126   	2.87
RH10125   	2.87
RH10124   	26.89
RH10123   	26.89
RH10122   	26.89
RH10121   	26.89
RH10120   	26.89
RH10119   	26.89
RH10118   	23.32
RH10117   	23.32
RH10116   	23.32
RH10115   	23.32
RH10114   	23.32
RH10113   	23.32
RH10112   	23.32
RH10111   	23.32
RH10110   	23.32
RH10109   	23.32
RH10108   	23.32
RH10107   	23.32
RH10106   	23.32
RH10105   	23.32
RH10104   	23.32
RH10103   	23.32
RH10102   	23.32
RH10101   	23.32
RH10100   	20.94
RH10099   	20.94
RH10098   	20.94
RH10097   	20.94
RH10096   	20.94
RH10095   	20.94
RH10094   	27.67
RH10093   	27.67
RH10092   	27.67
RH10091   	27.67
RH10090   	27.67
RH10089   	27.15
RH10088   	27.15
RH10087   	27.15
RH10086   	27.15
RH10085   	27.15
RH10084   	20.94
RH10083   	20.94
RH10082   	20.94
RH10081   	20.94
RH10080   	20.94
RH10079   	20.94
RH10078   	20.94
RH10077   	20.94
RH10076   	20.94
RH10075   	20.94
RH10074   	20.94
RH10073   	20.94
RH10072   	10.71
RH10071   	10.71
RH10070   	4.3
RH10069   	4.3
RH10068   	4.3
RH10067   	4.3
RH10066   	4.3
RH10065   	4.3
RH10064   	4.3
RH10063   	4.3
RH10062   	4.3
RH10061   	4.3
RH10039   	20.94
RH10038   	20.94
RH10037   	20.94
RH10036   	20.94
RH10035   	20.94
RH10034   	20.94
RH10033   	20.94
RH10032   	20.94
RH10031   	20.94
RH10030   	20.94
RH10029   	20.94
RH10028   	20.94
RH10027   	20.94
RH10026   	9.5
RH10025   	9.5
RH10024   	9.5
RH10023   	9.5
RH10022   	9.5
RH10021   	9.5
RH10020   	9.5
RH10019   	9.5
RH10018   	20.94
RH10017   	20.94
RH10016   	20.94
RH10015   	20.94
RH10014   	20.94
RH10013   	20.94
RH10012   	20.94
RH10011   	20.94
RH10010   	20.94
RH10009   	20.94
RH10008   	20.94
RH10007   	20.94
RH10006   	2.87
RH10005   	2.87
RH10004   	2.87
RH10003   	2.87
RH10002   	2.87
RH10001   	2.87
null      	21.84
null      	42.44
\.


--
-- TOC entry 3337 (class 0 OID 17015)
-- Dependencies: 216
-- Data for Name: dim_orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.dim_orders (order_date, revenue, total_sku_cost, margin, numberof_orders, tax, numberof_invalid_total_price, numberof_null_total_sku, numberof_negetive_margin, sum_negetive_margin) FROM stdin;
2022-08-01	3801.5198	1410.3495	1905.4305	50	610.14984	14	8	11	-780.35004
2022-08-02	2588.24	577.5101	1805.2401	27	375.78995	3	3	3	-50.94
2022-08-03	2032.95	332.18002	1254.29	23	325.64993	1	5	1	-17.32
2022-08-04	2007.6799	836.72003	914.45984	31	305.40997	12	5	10	-525.84
2022-08-05	2406.93	459.40002	1731.2903	27	338.05	4	4	3	-95.86
2022-08-06	2223.2798	356.73004	1781.05	16	310.41998	0	1	0	0
2022-08-07	5258.0005	1096.1	3810.13	42	798.8299	3	4	3	-53.08
2022-08-08	2559.4302	727.9801	1720.9502	29	329.15005	7	3	6	-199.94003
2022-08-09	1476.27	398.73004	982.55005	21	237.04996	6	2	5	-160.3
2022-08-10	1616.3699	255.80002	809.61993	17	260.41998	2	5	1	-20.94
\.


--
-- TOC entry 3336 (class 0 OID 16409)
-- Dependencies: 211
-- Data for Name: orders_line_items_toy_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_line_items_toy_data (sku, orders_line_items_price, orders_line_items_quantity, _airbyte_orders_hashid) FROM stdin;
RH10033   	79.82	1	da56624cc14a61cd83faf9fb4ea2eca5                  
RH10229   	13.44	1	160c5c5165d9dd6751b91949d7f4cc9a                  
RH10049   	79.82	1	160c5c5165d9dd6751b91949d7f4cc9a                  
RH10103   	50.42	1	c3e739688e923bd227f82fbfb6dab731                  
RH10104   	50.42	2	2f995b5740f47a6f6b1aaa73a81d2fbc                  
RH10122   	84.03	2	59bc0f5480efb74212e8f915de2a9bdb                  
RH10051   	25	1	656edf38396560e59aab77d59d088d2a                  
RH10319   	84.03	1	b1df7bb2224a8d23d42eb2cbdc608ea7                  
RH10049   	94.99	1	d13d807749eac3d43d111e2c70db5374                  
RH10117   	110.92	1	a263e5e43bedebd6a21b6e144b77f02c                  
RH10254   	59.99	1	f48e09599826b6f4825b9e13c824f7a9                  
RH10264   	50	1	df4c4ecbe8725f4170193943efe8fb94                  
RH10036   	94.99	1	6bc1e2a89f7f222e1c795433c6fe7486                  
RH10121   	100	1	e0fa187479623128cb15b7a30c1f6470                  
RH10239   	109.99	1	825f831a9e93d9d0aac059588fd2f0b4                  
RH10115   	109.99	1	3f28f83b0a0cc735fde2427d88df2603                  
RH10319   	100.84	1	61657233269fa67ced162515e9b6881a                  
RH10032   	94.99	1	e6af909e31abd66deaf40ccb1d81c82a                  
RH10033   	94.99	1	e6af909e31abd66deaf40ccb1d81c82a                  
RH10034   	94.99	1	e6af909e31abd66deaf40ccb1d81c82a                  
RH10035   	94.99	1	e6af909e31abd66deaf40ccb1d81c82a                  
RH10036   	94.99	1	e6af909e31abd66deaf40ccb1d81c82a                  
RH10056   	94.99	1	e6af909e31abd66deaf40ccb1d81c82a                  
RH10175   	59.99	3	415d8195153a3bd6bbde9fec5413ff5c                  
RH10176   	59.99	2	415d8195153a3bd6bbde9fec5413ff5c                  
RH10177   	59.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10179   	59.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10252   	59.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10253   	59.99	2	415d8195153a3bd6bbde9fec5413ff5c                  
RH10254   	59.99	2	415d8195153a3bd6bbde9fec5413ff5c                  
RH10255   	59.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10033   	94.99	3	415d8195153a3bd6bbde9fec5413ff5c                  
RH10034   	94.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10035   	94.99	2	415d8195153a3bd6bbde9fec5413ff5c                  
RH10036   	94.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10056   	94.99	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10232   	15.99	2	415d8195153a3bd6bbde9fec5413ff5c                  
RH10233   	15.99	5	415d8195153a3bd6bbde9fec5413ff5c                  
RH10261   	50	3	415d8195153a3bd6bbde9fec5413ff5c                  
RH10262   	50	2	415d8195153a3bd6bbde9fec5413ff5c                  
RH10263   	50	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10265   	50	1	415d8195153a3bd6bbde9fec5413ff5c                  
RH10229   	16.13	1	07fc48d6b8c3ff7e12d5f80f5b36e80e                  
RH10116   	110.92	1	07fc48d6b8c3ff7e12d5f80f5b36e80e                  
RH10057   	95.78	1	79be5263dcfd9c5c9bceb823ee1de0c2                  
RH10034   	94.99	1	f74f80a51b883b9294622a9a15690c65                  
RH10049   	94.99	1	e20c3cb67254e0dbb9cdc413d122f504                  
RH10318   	99.99	1	2bfb7bc4fd563609ef418e722c5ad066                  
RH10114   	110.92	1	70aff784747e97cb44082dec590d0f16                  
RH10102   	60	1	d24cea0645275a762af502348b379814                  
RH10114   	109.99	1	b15ee90d6ae59396df583a3a52683a69                  
RH10083   	94.99	1	2291f1899f05d624b2c2a6d052df63d0                  
RH10050   	94.99	1	3b19bc66eef0dabc4740c948e4025613                  
RH10235   	15.99	1	d1d6f214e860490371a6d6a2f4f7df94                  
RH10230   	15.99	1	d1d6f214e860490371a6d6a2f4f7df94                  
RH10033   	94.99	1	d1d6f214e860490371a6d6a2f4f7df94                  
RH10318   	99.99	1	e77724d6434199bcf56257094d1be0c6                  
RH10118   	109.99	1	c1d012759a3228cae5d687f2305643f2                  
RH10197   	94.99	1	5a42f782bac74b8e4c15f16be04133ba                  
RH10232   	15.99	1	5a42f782bac74b8e4c15f16be04133ba                  
RH10262   	50	1	5a42f782bac74b8e4c15f16be04133ba                  
RH10131   	35	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10049   	94.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10034   	94.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10081   	94.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10268   	29.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10257   	24.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10233   	15.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10229   	15.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10235   	15.99	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10262   	50	2	f6694111810cc975ba94d3ce5c28d11b                  
RH10263   	50	1	f6694111810cc975ba94d3ce5c28d11b                  
RH10177   	59.99	1	bff91f023a984333364b63f61b796cd5                  
RH10258   	24.99	1	bff91f023a984333364b63f61b796cd5                  
RH10184   	59.99	1	12816b493d6717b3568874057b46219f                  
RH10036   	94.99	1	12816b493d6717b3568874057b46219f                  
RH10259   	24.99	1	12816b493d6717b3568874057b46219f                  
RH10229   	16.26	1	b3fb7dfc7d8d70e239523219b5474fdb                  
RH10233   	15.99	1	12816b493d6717b3568874057b46219f                  
RH10182   	61	1	b3fb7dfc7d8d70e239523219b5474fdb                  
RH10132   	35.59	1	b3fb7dfc7d8d70e239523219b5474fdb                  
RH10082   	96.58	1	b3fb7dfc7d8d70e239523219b5474fdb                  
RH10183   	61	1	1efe2a01ef40fec446d1da6e75ea1e72                  
RH10123   	101.68	1	1efe2a01ef40fec446d1da6e75ea1e72                  
RH10057   	96.58	1	1efe2a01ef40fec446d1da6e75ea1e72                  
RH10231   	16.26	1	1efe2a01ef40fec446d1da6e75ea1e72                  
RH10239   	109.99	1	12b1486a0ab23ccbf885f5772d903122                  
RH10114   	109.99	1	693292448b94af9926897b0d66b6bf58                  
RH10049   	94.99	1	83bb17a2c140c3302da897f68cc76ca7                  
RH10081   	94.99	1	83bb17a2c140c3302da897f68cc76ca7                  
RH10114   	109.99	1	2af1dcf260ec0c5ecaab8f6ccefc0681                  
RH10117   	109.99	1	bfa21cff7645b2271c5d3748ba24f2f8                  
RH10049   	94.99	1	44aef03fb766d2add9c7ac92dc3cea81                  
RH10237   	109.99	1	8816f6d692cf4ab67ecda0e515ea6cfe                  
RH10080   	94.99	1	357cd70dc07bc6618b2c1cfbb382676d                  
RH10049   	94.99	1	7c0f4f05e35fa29bbbaedbe4152936e7                  
RH10032   	94.99	1	aee044bcd2f6e79883bf88723b4280d8                  
RH10229   	15.99	1	852b5677536df90e7fc381a46dde3596                  
RH10114   	109.99	1	852b5677536df90e7fc381a46dde3596                  
RH10228   	15.99	1	fbfea69c298070e95a492e1a41d3f0c7                  
RH10316   	99.99	1	fbfea69c298070e95a492e1a41d3f0c7                  
RH10250   	59.99	1	b453b708d40d8d368f3c2ea7376e4408                  
RH10232   	15.99	1	28750545d5533b08200d754b3a5a20e6                  
RH10113   	109.99	1	28750545d5533b08200d754b3a5a20e6                  
RH10233   	15.99	1	1babbb8c14858b72d9b159f73c3c0fed                  
RH10081   	95.78	1	86f473e2c88f8862ea019bae1b303538                  
RH10187   	49.99	1	c486d02e0b3f3378a4ab477d89a967ca                  
RH10131   	35	1	c486d02e0b3f3378a4ab477d89a967ca                  
RH10218   	24.99	1	c486d02e0b3f3378a4ab477d89a967ca                  
RH10228   	15.99	1	c486d02e0b3f3378a4ab477d89a967ca                  
RH10049   	94.99	1	c486d02e0b3f3378a4ab477d89a967ca                  
RH10252   	59.99	1	c486d02e0b3f3378a4ab477d89a967ca                  
RH10115   	109.99	1	c97cbb2955539448320710a6c2b59da4                  
RH10081   	94.99	1	9f840054e0c41b60390dcd58cd8240b1                  
RH10238   	109.99	1	9f840054e0c41b60390dcd58cd8240b1                  
RH10051   	25	1	8519ffd8a29e7e2dcbd8c5a6df7e0ec9                  
RH10239   	109.99	1	cd13a429c5b7329d75f1bd025740cd74                  
RH10219   	24.99	1	a3cbf1f7d0de541fe3f6dabc3f1515cf                  
RH10238   	109.99	1	80cb5f51c2ce45be3ac2f09bcb41a77b                  
RH10082   	94.99	1	351ad775d54445c35f04de378b81a4e2                  
RH10319   	100.84	1	507f8586144969b127e03c11066dab55                  
RH10034   	94.99	1	9b173a0ac55d1e110d2d0e19d575948d                  
RH10116   	109.99	1	e30d5336e108fc1be0763b39cae59dae                  
RH10048   	94.99	1	752847621d2d7fa3a8e80500b4e7836a                  
RH10115   	109.99	1	f9bed81ca18ccad7c646263e641fa37a                  
RH10238   	109.99	1	e24e721abe880c3c3def897e1c131431                  
RH10114   	109.99	1	4567a1d1dc024dcd2067f924302dcc22                  
RH10318   	100.84	1	2e70aa41ea9ac357f3764e70fd4e2ca3                  
RH10102   	60	1	1eaae8a978b240655e281b2b2d1a4495                  
RH10114   	109.99	1	1eaae8a978b240655e281b2b2d1a4495                  
RH10082   	79.82	1	75d88ae1698b94584840b63e11b5a2b2                  
RH10148   	63.02	1	f06ac9fd1b610d8aa41a7bf6223581fe                  
RH10321   	84.03	1	f06ac9fd1b610d8aa41a7bf6223581fe                  
RH10121   	100	1	1218474a276a0ced92adc3803e19cb39                  
RH10239   	109.99	1	57ab0d552e11e3f4ead6fa758a37cfa7                  
RH10319   	99.99	1	aed890e3c086bf1a9eda6eed52cacb51                  
RH10139   	35	1	5a98c6ffd1c710444369bd15c67cfc87                  
RH10258   	24.99	1	251af0490427b360c0589c38b7649f0e                  
RH10231   	15.99	1	251af0490427b360c0589c38b7649f0e                  
RH10104   	60	1	251af0490427b360c0589c38b7649f0e                  
RH10082   	94.99	1	2d0ddb095dc61b5f7a760cb71cb76732                  
RH10104   	60	1	769cebc4ac4cf6e81d835bfc63eba3f6                  
RH10033   	94.99	1	aa5f2af9d33b6e57fe5a09756e610baa                  
RH10057   	94.99	1	54225ce86824da597a05192bf9a093c4                  
RH10147   	74.99	1	fb305ad7e0d80627af1642cd1ac2350d                  
RH10049   	94.99	1	8da0059ba097f053451a97b68f7995d5                  
RH10253   	60.49	1	9ddfc0a5798f8aabafcffbd1d4f12e0e                  
RH10080   	95.78	1	9ddfc0a5798f8aabafcffbd1d4f12e0e                  
RH10319   	100.84	1	ab85e3065ae320b648c9d0b2c402c777                  
RH10302   	25.2	1	ab85e3065ae320b648c9d0b2c402c777                  
RH10238   	109.99	1	f3322796adb2454367973de02cbfc310                  
RH10049   	94.99	1	53f602d286890fc5021be78e8105b2cb                  
RH10238   	109.99	1	21515f919ceb41131bb8ad9d29e4271b                  
RH10218   	24.99	1	21515f919ceb41131bb8ad9d29e4271b                  
RH10238   	109.99	1	15461ae9153da93cf83cdcace13ff655                  
RH10214   	24.99	1	ad6f435c6e1e7041a986c71e216bcc76                  
RH10320   	99.99	1	77cd880ee3ff5eb19ad3aef094963b06                  
RH10117   	109.99	1	2fd04fde20fa83fd36a1a7b9868a6380                  
RH10102   	60	1	f4be675eba1717c635cd7ef288debaaa                  
RH10228   	15.99	1	d12f18126ec70571eb52ed3e28f69ce7                  
RH10317   	99.99	1	c023e53da05c8d5baf5d88c1fcc96603                  
RH10237   	109.99	1	f8e8e7231726fee3132c9dbc9fab9605                  
RH10057   	94.99	1	ef0e06923a0f93127f68d9535d5f37cc                  
RH10319   	99.99	1	78ed01835a2d25a48d045e8db9b0dcfd                  
RH10122   	100	1	78ed01835a2d25a48d045e8db9b0dcfd                  
RH10176   	59.99	1	6b8622e04290bc45514963be63415313                  
RH10035   	94.99	1	6b8622e04290bc45514963be63415313                  
RH10231   	15.99	1	6b8622e04290bc45514963be63415313                  
RH10175   	59.99	1	77c3a006172d5218f5f86962b8115efd                  
RH10218   	24.99	1	77c3a006172d5218f5f86962b8115efd                  
RH10237   	109.99	1	77c3a006172d5218f5f86962b8115efd                  
RH10228   	15.99	1	77c3a006172d5218f5f86962b8115efd                  
RH10175   	59.99	1	05f4c209fb962406fc856ba45cf04738                  
RH10049   	95.78	1	93a8d574a380fbf57b3153c9902fac0b                  
RH10257   	25.2	1	93a8d574a380fbf57b3153c9902fac0b                  
RH10114   	109.99	1	7004aafd7f4518abc9614bf29ca0ec6e                  
RH10114   	109.99	1	3bd987f3eee9eecbcbe7b5bd50211afb                  
RH10034   	94.99	1	5ffbec1de1497e4d41f15a4f8554604c                  
RH10048   	94.99	1	a36c35c337946efe3d7e457da2b82fb9                  
RH10318   	99.99	1	04e777dedbdec659a539e3a2b0850718                  
RH10137   	35	1	ffe5eff33393de9bf4cd83ed05a27584                  
RH10138   	35	1	ffe5eff33393de9bf4cd83ed05a27584                  
RH10139   	35	1	ffe5eff33393de9bf4cd83ed05a27584                  
RH10140   	35	1	ffe5eff33393de9bf4cd83ed05a27584                  
RH10181   	59.99	1	1fb1dc05c44a5f4df3485cfad9775305                  
RH10176   	59.99	1	1fb1dc05c44a5f4df3485cfad9775305                  
RH10034   	94.99	1	1fb1dc05c44a5f4df3485cfad9775305                  
RH10235   	15.99	1	1fb1dc05c44a5f4df3485cfad9775305                  
RH10317   	99.99	1	1025dc4bf69d509750c0733512975c44                  
RH10175   	59.99	1	19a342d1f983a5a7ef2fc7796ded25a0                  
RH10176   	59.99	1	19a342d1f983a5a7ef2fc7796ded25a0                  
RH10177   	59.99	1	19a342d1f983a5a7ef2fc7796ded25a0                  
RH10178   	59.99	1	19a342d1f983a5a7ef2fc7796ded25a0                  
RH10179   	59.99	1	19a342d1f983a5a7ef2fc7796ded25a0                  
RH10084   	94.99	1	3e8c72c4f67d0a939a01a5434e4be20d                  
RH10238   	109.99	1	5dfec0f89520b0d6b55b1203376bc38e                  
RH10181   	59.99	1	4969f023fb0cff7f0389a1bbdc5d794e                  
RH10176   	59.99	1	4969f023fb0cff7f0389a1bbdc5d794e                  
RH10034   	94.99	1	4969f023fb0cff7f0389a1bbdc5d794e                  
RH10235   	15.99	1	4969f023fb0cff7f0389a1bbdc5d794e                  
RH10258   	24.99	1	949266fe313c699fc17f385186136b20                  
RH10034   	94.99	1	8bb36ee2b35a6ab457db7c548132a5e6                  
RH10235   	15.99	1	2fc252b971fbf2f5bfb3b34b6dc678b0                  
RH10319   	99.99	1	e7da29db8af8c2f959d7f36d9b7b1b0c                  
RH10231   	15.99	1	c085ac1c3855745d54e52a47e2d611fc                  
RH10218   	24.99	1	c085ac1c3855745d54e52a47e2d611fc                  
RH10048   	94.99	1	c085ac1c3855745d54e52a47e2d611fc                  
RH10048   	94.99	1	6cad7d95a5ecd0d5e4131845b3a15142                  
RH10117   	109.99	1	64fde1b78cb2339d4a9eb4356a15dbe6                  
RH10318   	99.99	1	0c44c8039dc4a7c8db601a96c2e584be                  
RH10318   	99.99	1	2256933543a92d44aa0f02c044473961                  
RH10239   	109.99	1	0a34fbb70f9f59ce96a482dab19fc0cf                  
RH10057   	94.99	1	365baa7512d7dc537657db617c2ccea3                  
RH10235   	15.99	1	a675a0202e19860e95e665ca38d85009                  
RH10319   	99.99	1	a675a0202e19860e95e665ca38d85009                  
RH10054   	100	1	d6f9d4d22ff963e79e29ade15492127c                  
RH10230   	15.99	1	3f6a2bb4be2fb4e58cfa37038e54bc9a                  
RH10127   	10	1	eee49a828680286371255b94336c5c97                  
RH10113   	109.99	1	ca528551a4294fe5291f46cb2bbd6c82                  
RH10083   	94.99	1	47e3804b31d12d069c326690856e5256                  
RH10121   	100	1	2cb24cd83d715caf20ca89e6f2f49f68                  
RH10047   	94.99	1	4b18122819428cddb26f57c76983e44c                  
RH10319   	99.99	1	f73054fa5e9f1b051f7d571e22aa26b7                  
RH10049   	95.78	1	6aaeeb47f18924117361142698dde0da                  
RH10128   	10	1	7118e31fba5d897fc312125f46abbd3c                  
RH10114   	109.99	1	7118e31fba5d897fc312125f46abbd3c                  
RH10181   	59.99	1	e907fd32865b5158c3ae86cc4a22babd                  
RH10034   	94.99	1	e907fd32865b5158c3ae86cc4a22babd                  
RH10318   	99.99	1	e907fd32865b5158c3ae86cc4a22babd                  
RH10296   	24.99	1	8213f695278a207f020c3a45e41584a1                  
RH10199   	94.99	1	610736d01dee1e335c3b9644aed5234f                  
RH10198   	94.99	1	610736d01dee1e335c3b9644aed5234f                  
RH10049   	94.99	1	cbe3f7c8eeb0fe63d94e7266619846c2                  
RH10034   	94.99	1	cbe3f7c8eeb0fe63d94e7266619846c2                  
RH10239   	109.99	1	ca8435009c45586efeb41c0022052971                  
RH10238   	109.99	1	cc9cdd06b3fc8b84ad4b04aaae9cf815                  
RH10229   	15.99	1	fa34fcae4e6831d327e50d6c294c7b8d                  
RH10239   	109.99	1	fa34fcae4e6831d327e50d6c294c7b8d                  
RH10079   	94.99	1	b5e7bc68d6e722ed1634b954ee0b82ee                  
RH10320   	99.99	1	0bf82fc8f779e108aa1dc0366a18f8cb                  
RH10240   	109.99	1	8ee4b37249ef259535f8874748447aab                  
RH10229   	15.99	1	8274c865895e5db3cdfe5cd8b5279067                  
RH10238   	109.99	1	8274c865895e5db3cdfe5cd8b5279067                  
RH10249   	59.99	1	964d0939acdf6da792de039f051ebb16                  
RH10105   	60.5	1	176ab428b21d3f92d00f30b864782053                  
RH10318   	99.99	1	c282991612d4df5d2ca2c89583d4eeac                  
RH10050   	94.99	1	0e39807822e4f63bc1d32bbc548a5f8c                  
RH10250   	59.99	1	73c3b3496d3f3b7384141084556565ab                  
RH10258   	24.99	1	73c3b3496d3f3b7384141084556565ab                  
RH10148   	74.99	1	eb1dbb78bab0db200e57420d507ea0de                  
RH10198   	94.99	1	c3e2867a02b550e24ec750af06fbf15d                  
RH10034   	94.99	1	f47ad0bc3097e24970301ce2323253c3                  
RH10239   	109.99	1	2c50970bd401186ca294d6fb48dd0b0c                  
RH10236   	92.43	1	faa312df8188741c3affa032c9e6fa62                  
RH10050   	95.78	1	2cae45eb8fa80ae8772431630eff178e                  
RH10034   	94.99	1	b481115f4025f5e6b6a6ce0405bdf48a                  
RH10182   	59.99	1	95764313f1be6c9c40ab4d1e93de801b                  
RH10082   	94.99	1	95764313f1be6c9c40ab4d1e93de801b                  
RH10117   	109.99	1	95764313f1be6c9c40ab4d1e93de801b                  
RH10229   	15.99	1	6504382e86d584ba7fc6f67ca2f11673                  
RH10319   	99.99	1	6504382e86d584ba7fc6f67ca2f11673                  
RH10318   	99.99	1	30df1f4de17799d30ac1d3be6c5167ec                  
RH10128   	10	1	f9c857419c6b90ba64d3a9528ed2048f                  
RH10114   	109.99	1	9c3b47439652e840e5f96915bc9ba6d8                  
RH10049   	95.78	1	66f58b0d2ebcfd7722af08e95c62fdba                  
RH10238   	110.92	1	66f58b0d2ebcfd7722af08e95c62fdba                  
RH10237   	109.99	1	57d6b06cd25a1991827934d673db177f                  
RH10114   	109.99	1	57d6b06cd25a1991827934d673db177f                  
RH10079   	94.99	1	8678792d5c2b96f0b9ba98ce76ce2839                  
RH10032   	94.99	1	8678792d5c2b96f0b9ba98ce76ce2839                  
RH10239   	109.99	1	55daa7ea5011ed70e1d1797911e727ad                  
RH10239   	109.99	1	4825f6a656c846e42d36fed3a58a225d                  
RH10230   	16.13	1	96a600f335b409657e428be059348e4e                  
RH10267   	30.24	1	96a600f335b409657e428be059348e4e                  
RH10237   	110.92	1	96a600f335b409657e428be059348e4e                  
RH10080   	95.78	1	96a600f335b409657e428be059348e4e                  
RH10238   	109.99	1	47a181c2893420aef9c5baf20e2f6088                  
RH10318   	99.99	1	7b97e043d05348c763fbec7a9295eb6b                  
RH10199   	94.99	1	dad6672e4b7658cde8fa3f48117febc6                  
RH10035   	94.99	1	dc518045d818be5dba4e003ce6deb884                  
RH10187   	42.01	2	d91c03b7d92daf46d3e55b20e032b81b                  
RH10053   	75	1	2695479f0a6fed4255207db0bc35381e                  
RH10115   	109.99	1	1af49f9d4b0a99c57925a8c702b0ec0b                  
RH10237   	109.99	1	e10ef6bfcbb044d13336e235f645dacd                  
RH10050   	94.99	1	798bd8f62c3110e10081f6f22c7f0e9c                  
RH10128   	10	1	b3336afc40747232f07a13e4c400039c                  
RH10235   	15.99	1	b3336afc40747232f07a13e4c400039c                  
RH10240   	109.99	1	b3336afc40747232f07a13e4c400039c                  
RH10105   	60	1	b3336afc40747232f07a13e4c400039c                  
RH10083   	94.99	1	7ee44ec2dbac12d56f7fccd7a751b92d                  
RH10199   	94.99	1	7ee44ec2dbac12d56f7fccd7a751b92d                  
RH10034   	95.78	1	8139228413f857ee682cd8f3a1ec33cf                  
RH10032   	94.99	1	495e460113f1e4bf186a32d2e7a55d3a                  
RH10228   	15.99	1	495e460113f1e4bf186a32d2e7a55d3a                  
RH10229   	16.13	1	af9738bbf76cb5b21fef35c7baaf8594                  
RH10079   	95.78	1	af9738bbf76cb5b21fef35c7baaf8594                  
RH10218   	25.2	1	af9738bbf76cb5b21fef35c7baaf8594                  
RH10238   	109.99	1	9c7996898568480ffc3dd85472d26a55                  
RH10033   	94.99	1	12d670eee4894671a56444ba05e25a18                  
RH10079   	94.99	1	f6cf87212eb2443014e6f10955729904                  
RH10239   	109.99	1	1a9dadd810f98bfede9abac4667024b7                  
RH10319   	99.99	1	10dd94d65977c0d68e963aa9b3dc1503                  
RH10198   	94.99	1	1a9dadd810f98bfede9abac4667024b7                  
RH10253   	50.41	1	c3e739688e923bd227f82fbfb6dab731                  
RH10183   	61	1	2ec204382f49a8d3e283ee34cb4d262c                  
RH10193   	61	1	2ec204382f49a8d3e283ee34cb4d262c                  
RH10104   	60	1	f4259c66c27eabdec5bae18678cbb61f                  
RH10083   	96.58	1	2ec204382f49a8d3e283ee34cb4d262c                  
RH10229   	16.26	1	2ec204382f49a8d3e283ee34cb4d262c                  
RH10233   	15.99	1	5d65c8613eaa2e1f14bb06d71b8bc558                  
RH10319   	99.99	1	5d65c8613eaa2e1f14bb06d71b8bc558                  
RH10200   	94.99	1	3dbc23ab9e89840c08af9ae7252fda3f                  
RH10131   	35	1	418f2cd8aba80cb04a4274e2f78fe1db                  
RH10034   	94.99	1	418f2cd8aba80cb04a4274e2f78fe1db                  
RH10229   	15.99	1	418f2cd8aba80cb04a4274e2f78fe1db                  
RH10262   	50	1	418f2cd8aba80cb04a4274e2f78fe1db                  
RH10238   	109.99	1	7bf399d2b8e47419f17c1ca963ca72bc                  
RH10238   	109.99	1	9808e9c4cb4c69fb216c99b1acd0882f                  
RH10233   	15.99	1	9808e9c4cb4c69fb216c99b1acd0882f                  
RH10263   	50	1	9808e9c4cb4c69fb216c99b1acd0882f                  
RH10102   	60	1	9158c873c84b4458d48801473be4226e                  
RH10049   	94.99	1	7bf399d2b8e47419f17c1ca963ca72bc                  
RH10133   	35	1	d64cf7ee92f0daed6a2427f33d070fa1                  
RH10035   	94.99	1	d64cf7ee92f0daed6a2427f33d070fa1                  
RH10128   	10	1	d64cf7ee92f0daed6a2427f33d070fa1                  
RH10050   	94.99	1	aaa5a41b62921d18c87994482aa584bd                  
RH10319   	99.99	1	37170b54cd9c6341a59d93480a9778a6                  
RH10104   	60	1	c76b40d624a1e4d3a12b954d23f48c40                  
RH10116   	109.99	1	708c4d67b42b051f4a02a9f075249cc0                  
RH10102   	60	1	903ab841e4cd7a190251a64ad3a1f7d0                  
RH10104   	60	1	35a4831df4592138157143741697f200                  
RH10228   	15.99	1	b817cbe8a41d9b42e124bdea8a9d8df7                  
RH10079   	94.99	1	b817cbe8a41d9b42e124bdea8a9d8df7                  
RH10239   	109.99	1	b11da2885481c5a887f793ebb371f1c6                  
RH10319   	99.99	1	80c2bc4aab81fabfe23b151ec38b0c56                  
RH10303   	24.99	1	80c2bc4aab81fabfe23b151ec38b0c56                  
RH10317   	99.99	1	9c65d56209983b633db1966d2fbe9828                  
RH10240   	110.92	1	04f0a2ba123cdcd3a439ffcd23df6914                  
RH10080   	94.99	1	4f9c342550e3f83e60487b3162008921                  
RH10048   	94.99	1	c84283d1e5e73ac57852ac1174ef3c90                  
RH10176   	59.99	1	ac6e8b7b40d8a4f6d884eb5749ac90e4                  
RH10033   	94.99	1	ac6e8b7b40d8a4f6d884eb5749ac90e4                  
RH10317   	99.99	1	ac6e8b7b40d8a4f6d884eb5749ac90e4                  
RH10147   	74.99	1	9791a19828053e297ca5b10b7197e2f8                  
RH10050   	79.82	1	b1df7bb2224a8d23d42eb2cbdc608ea7                  
RH10048   	94.99	1	2faf1aa4f052e22b3a2072315f84d8fa                  
RH10083   	94.99	1	1650a3aeffd054bea126b003755b7443                  
RH10082   	94.99	1	1650a3aeffd054bea126b003755b7443                  
RH10117   	109.99	1	1650a3aeffd054bea126b003755b7443                  
RH10035   	94.99	1	e98ca456b3d247858aa0aaeecb651fb9                  
RH10318   	99.99	1	531e4c7b3048cff204d054f429f5a813                  
RH10080   	94.99	1	6b13013834143c2b5a713d6bd8197a58                  
RH10049   	94.99	1	1e78ed17594624d8f0c37301ae71d9ef                  
RH10034   	94.99	1	3a1e231cfe02d7b1337bfe94797b643c                  
RH10035   	94.99	1	1ef263da718f6979ec6dc84a4c41af0b                  
RH10218   	24.99	1	be2acdf64bfb5d074dfc454e1c73f0d4                  
RH10236   	109.99	1	be2acdf64bfb5d074dfc454e1c73f0d4                  
RH10228   	15.99	1	be2acdf64bfb5d074dfc454e1c73f0d4                  
RH10181   	61	1	dfdd017b69d1ae5c18049276c333647d                  
RH10175   	61	1	dfdd017b69d1ae5c18049276c333647d                  
RH10230   	15.99	1	05aafb5869ef4cca7f52ab52ccc7a88d                  
RH10049   	96.58	1	dfdd017b69d1ae5c18049276c333647d                  
RH10229   	16.26	1	dfdd017b69d1ae5c18049276c333647d                  
RH10080   	95.78	1	6c57092f3115a688afa077653dfdaa55                  
RH10321   	99.99	1	d4bd60f3839ce2c4ba60abb0730e9c07                  
RH10219   	24.99	1	05aafb5869ef4cca7f52ab52ccc7a88d                  
RH10114   	109.99	1	05aafb5869ef4cca7f52ab52ccc7a88d                  
RH10318   	99.99	1	80f2e7b5acca6f9c108c05ee9e9e3867                  
RH10238   	109.99	1	80f2e7b5acca6f9c108c05ee9e9e3867                  
RH10050   	94.99	1	6e38a4abf6ddfd9a6b010ca690313329                  
RH10128   	10	1	ba9ff84a502e56d3c60437c2230205f0                  
RH10318   	99.99	1	e1d1d12edb578eaf2af957698d46fc65                  
RH10238   	109.99	1	2098db48be0b1da1510336bf888885a4                  
RH10081   	94.99	1	2098db48be0b1da1510336bf888885a4                  
RH10080   	95.78	1	04b02865c286355d5be579a47b1c1c61                  
RH10218   	24.99	1	dfa57ebb3add845905337876dd0e7171                  
RH10239   	109.99	1	e703600604e7bec16417c935ee597802                  
RH10079   	94.99	1	018f22097e0ac0dfb92f1bc8673aa5cf                  
RH10320   	99.99	1	4912e46a36da7dc97b5dae112d166cb8                  
RH10048   	94.99	1	797be05e39512dac457b2b6e2feb908c                  
RH10225   	24.99	1	e9d494ff36c3e8b3b4c0e7a57b141824                  
RH10220   	24.99	1	e9d494ff36c3e8b3b4c0e7a57b141824                  
RH10321   	99.99	1	d93d3192a6326c7a81aff1ba8abd79bc                  
RH10320   	99.99	1	d93d3192a6326c7a81aff1ba8abd79bc                  
RH10316   	99.99	1	027109b899582228b1468f907497469a                  
RH10049   	94.99	2	3d7cff159045cb0e40173b19ed91f8b8                  
RH10049   	94.99	1	a38f2c34bf2453b8f5ba22f1420a7bcb                  
RH10049   	94.99	1	8c417a1c8a6392216ecdc772eed4cbcd                  
RH10034   	94.99	1	b56eac66b9a4ab2d71af86c36982e925                  
RH10058   	94.99	1	ae6ec4a2d7414385669138c3b143ec83                  
RH10122   	102.52	1	cdb1a07e4877a7f3d88a68e9efebb552                  
RH10239   	109.99	1	213f64c064995c81ddca06d1204ae4c7                  
RH10198   	94.99	1	6f5bd61a94b41d7629f5adac7cd7a924                  
RH10239   	109.99	1	918891ec4b482632eb6315d71e3796b0                  
RH10081   	94.99	1	d26c565347d18cc902b35126ceae4a4e                  
RH10254   	59.99	1	56ed058fa0f485160da952b43497adcc                  
RH10188   	49.99	1	56ed058fa0f485160da952b43497adcc                  
RH10226   	24.99	1	56ed058fa0f485160da952b43497adcc                  
RH10133   	35	1	56ed058fa0f485160da952b43497adcc                  
RH10233   	15.99	1	56ed058fa0f485160da952b43497adcc                  
RH10128   	10	1	36ebba400c45f1b63d3a247d2223af77                  
RH10114   	109.99	1	f251c6fa1198d1194694cb6f9c14e2b9                  
RH10082   	79.82	1	ee786784e7c477d4dbaf95172c0ac5e9                  
RH10034   	94.99	1	9eb7fca8a58d32e2cb155338506df423                  
RH10318   	99.99	1	9eb7fca8a58d32e2cb155338506df423                  
RH10049   	94.99	1	9eb7fca8a58d32e2cb155338506df423                  
RH10083   	94.99	1	1b611b49e172c5c029335eda8d0bc96c                  
RH10117   	109.99	1	eb3151c4948a7bc26861bc81e2195d28                  
RH10114   	109.99	1	eb3151c4948a7bc26861bc81e2195d28                  
RH10320   	99.99	1	4f7abe322768d337bb97001ec7349335                  
RH10317   	100.84	1	23e295c214b3411a9ed7cd5eca042f07                  
RH10238   	109.99	1	ef8c50d53b7c588584effbd4c71f6228                  
RH10034   	94.99	1	ef8c50d53b7c588584effbd4c71f6228                  
RH10033   	94.99	1	ef8c50d53b7c588584effbd4c71f6228                  
RH10114   	109.99	1	ef8c50d53b7c588584effbd4c71f6228                  
RH10319   	99.99	1	14dbeb10ee02e2a354f289aa548092fe                  
RH10318   	99.99	1	14dbeb10ee02e2a354f289aa548092fe                  
RH10137   	35	1	6167176720d298408358c9f7693f6419                  
RH10138   	35	1	6167176720d298408358c9f7693f6419                  
RH10139   	35	2	6167176720d298408358c9f7693f6419                  
RH10049   	94.99	1	1e82f6c8dc1e69a66a4bd4352176804b                  
RH10317   	99.99	1	1e82f6c8dc1e69a66a4bd4352176804b                  
RH10056   	94.99	1	e122ecaf73554016672ddac07a0566cf                  
RH10113   	109.99	1	44e364b3896c4befc03a53a9a6329457                  
RH10147   	74.99	1	f47b9fcd87314d5be616952e19a32ed8                  
RH10256   	24.99	1	57478f69b6ba06d2b88bdfd52d0ccd75                  
RH10137   	35	1	57478f69b6ba06d2b88bdfd52d0ccd75                  
RH10047   	94.99	1	57478f69b6ba06d2b88bdfd52d0ccd75                  
RH10218   	24.99	1	57478f69b6ba06d2b88bdfd52d0ccd75                  
RH10221   	24.99	1	652851ff27d93d3ce01226c5d83232e4                  
RH10220   	24.99	1	652851ff27d93d3ce01226c5d83232e4                  
RH10238   	109.99	1	652851ff27d93d3ce01226c5d83232e4                  
RH10239   	109.99	1	652851ff27d93d3ce01226c5d83232e4                  
RH10320   	100.84	1	26d81d5765656cb08863d0e9ff6e61b3                  
RH10319   	100.84	1	26d81d5765656cb08863d0e9ff6e61b3                  
RH10318   	99.99	1	333effaafd521f2bbd140b8b4605bfad                  
RH10219   	24.99	1	d7fee8563f0c909cdd1b7f1a1c8d9926                  
RH10114   	109.99	1	d7fee8563f0c909cdd1b7f1a1c8d9926                  
RH10034   	79.82	1	a2974b4ef373ef463e8ec57b2a185640                  
RH10033   	79.82	1	a2974b4ef373ef463e8ec57b2a185640                  
RH10049   	94.99	1	3058c702085ede77be5440ffafa97393                  
RH10048   	94.99	1	3058c702085ede77be5440ffafa97393                  
RH10317   	99.99	1	3058c702085ede77be5440ffafa97393                  
RH10318   	99.99	1	3058c702085ede77be5440ffafa97393                  
RH10238   	110.92	1	842e3aa5504cf1df9720dd780e8075d4                  
RH10237   	109.99	1	5b9759fc389ba5be84ab7ceddd53b9d7                  
RH10320   	99.99	1	e8322419cfe15c70a97179bbd4925637                  
RH10319   	99.99	1	e8322419cfe15c70a97179bbd4925637                  
RH10148   	74.99	1	95739a00daccad42b9d6d5e361139665                  
RH10103   	60	1	c01e127c3832c473118b8f653d40566a                  
RH10219   	24.99	1	c01e127c3832c473118b8f653d40566a                  
RH10080   	94.99	1	22f33b000c8186a7967c2657b00e0374                  
RH10048   	94.99	1	22f33b000c8186a7967c2657b00e0374                  
RH10114   	109.99	1	22f33b000c8186a7967c2657b00e0374                  
RH10316   	99.99	1	edb2719ef9c5d071f4f0ef0f43c6c551                  
RH10049   	94.99	1	6404fe3f86b38f36be2f6cd1fe7cd998                  
RH10048   	94.99	1	6404fe3f86b38f36be2f6cd1fe7cd998                  
RH10240   	109.99	1	1bfa13e05bfd4a4706d108c5903b758e                  
RH10239   	109.99	1	1bfa13e05bfd4a4706d108c5903b758e                  
RH10260   	24.99	1	e8e1d8e9413af082e2f2980963a6e331                  
RH10250   	59.99	1	e8e1d8e9413af082e2f2980963a6e331                  
RH10147   	74.99	1	e8e1d8e9413af082e2f2980963a6e331                  
\.


--
-- TOC entry 3335 (class 0 OID 16406)
-- Dependencies: 210
-- Data for Name: orders_toy_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders_toy_data (created_at, total_price, total_price_without_tax, _airbyte_orders_hashid) FROM stdin;
2022-08-01	94.99	79.82	d13d807749eac3d43d111e2c70db5374                  
2022-08-01	0	0	a263e5e43bedebd6a21b6e144b77f02c                  
2022-08-01	0	0	f48e09599826b6f4825b9e13c824f7a9                  
2022-08-01	0	0	df4c4ecbe8725f4170193943efe8fb94                  
2022-08-01	0	0	6bc1e2a89f7f222e1c795433c6fe7486                  
2022-08-01	100	84.03	e0fa187479623128cb15b7a30c1f6470                  
2022-08-01	109.99	92.43	825f831a9e93d9d0aac059588fd2f0b4                  
2022-08-01	109.99	92.43	3f28f83b0a0cc735fde2427d88df2603                  
2022-08-01	110.84	92.36	61657233269fa67ced162515e9b6881a                  
2022-08-01	0	0	e6af909e31abd66deaf40ccb1d81c82a                  
2022-08-01	0	0	415d8195153a3bd6bbde9fec5413ff5c                  
2022-08-01	120.92	100.76	07fc48d6b8c3ff7e12d5f80f5b36e80e                  
2022-08-01	105.78	88.15	79be5263dcfd9c5c9bceb823ee1de0c2                  
2022-08-01	94.99	79.82	f74f80a51b883b9294622a9a15690c65                  
2022-08-01	0	0	e20c3cb67254e0dbb9cdc413d122f504                  
2022-08-01	90	75.63	2bfb7bc4fd563609ef418e722c5ad066                  
2022-08-01	109.83	91.52	70aff784747e97cb44082dec590d0f16                  
2022-08-01	60	50.42	d24cea0645275a762af502348b379814                  
2022-08-01	99	83.19	b15ee90d6ae59396df583a3a52683a69                  
2022-08-01	85.5	71.85	2291f1899f05d624b2c2a6d052df63d0                  
2022-08-01	94.99	79.82	3b19bc66eef0dabc4740c948e4025613                  
2022-08-01	114.28	96.03	d1d6f214e860490371a6d6a2f4f7df94                  
2022-08-01	90	75.63	e77724d6434199bcf56257094d1be0c6                  
2022-08-01	109.99	92.43	c1d012759a3228cae5d687f2305643f2                  
2022-08-01	0	0	5a42f782bac74b8e4c15f16be04133ba                  
2022-08-01	0	0	f6694111810cc975ba94d3ce5c28d11b                  
2022-08-01	0	0	bff91f023a984333364b63f61b796cd5                  
2022-08-01	0	0	12816b493d6717b3568874057b46219f                  
2022-08-01	0	0	b3fb7dfc7d8d70e239523219b5474fdb                  
2022-08-01	0	0	1efe2a01ef40fec446d1da6e75ea1e72                  
2022-08-01	99	83.19	12b1486a0ab23ccbf885f5772d903122                  
2022-08-01	109.99	92.43	693292448b94af9926897b0d66b6bf58                  
2022-08-01	0	0	83bb17a2c140c3302da897f68cc76ca7                  
2022-08-01	99	83.19	2af1dcf260ec0c5ecaab8f6ccefc0681                  
2022-08-01	109.99	92.43	bfa21cff7645b2271c5d3748ba24f2f8                  
2022-08-01	94.99	79.82	44aef03fb766d2add9c7ac92dc3cea81                  
2022-08-01	99	83.19	8816f6d692cf4ab67ecda0e515ea6cfe                  
2022-08-01	94.99	79.82	357cd70dc07bc6618b2c1cfbb382676d                  
2022-08-01	94.99	79.82	7c0f4f05e35fa29bbbaedbe4152936e7                  
2022-08-01	94.99	79.82	aee044bcd2f6e79883bf88723b4280d8                  
2022-08-01	100.79	84.7	852b5677536df90e7fc381a46dde3596                  
2022-08-01	104.39	87.72	fbfea69c298070e95a492e1a41d3f0c7                  
2022-08-01	54	45.38	b453b708d40d8d368f3c2ea7376e4408                  
2022-08-01	113.39	95.28	28750545d5533b08200d754b3a5a20e6                  
2022-08-01	15.99	13.44	1babbb8c14858b72d9b159f73c3c0fed                  
2022-08-02	96.21	80.17	86f473e2c88f8862ea019bae1b303538                  
2022-08-02	280.95	236.09	c486d02e0b3f3378a4ab477d89a967ca                  
2022-08-02	109.99	92.43	c97cbb2955539448320710a6c2b59da4                  
2022-08-02	184.49	155.03	9f840054e0c41b60390dcd58cd8240b1                  
2022-08-02	25	25	8519ffd8a29e7e2dcbd8c5a6df7e0ec9                  
2022-08-02	0	0	cd13a429c5b7329d75f1bd025740cd74                  
2022-08-02	0	0	a3cbf1f7d0de541fe3f6dabc3f1515cf                  
2022-08-02	109.99	92.43	80cb5f51c2ce45be3ac2f09bcb41a77b                  
2022-08-02	94.99	79.82	351ad775d54445c35f04de378b81a4e2                  
2022-08-02	90.68	75.56	507f8586144969b127e03c11066dab55                  
2022-08-02	80.75	67.86	9b173a0ac55d1e110d2d0e19d575948d                  
2022-08-02	99	83.19	e30d5336e108fc1be0763b39cae59dae                  
2022-08-02	85.5	71.85	752847621d2d7fa3a8e80500b4e7836a                  
2022-08-02	0	0	f9bed81ca18ccad7c646263e641fa37a                  
2022-08-02	109.99	92.43	e24e721abe880c3c3def897e1c131431                  
2022-08-02	109.99	92.43	4567a1d1dc024dcd2067f924302dcc22                  
2022-08-02	110.84	92.36	2e70aa41ea9ac357f3764e70fd4e2ca3                  
2022-08-02	153	128.57	1eaae8a978b240655e281b2b2d1a4495                  
2022-08-02	79.82	79.82	75d88ae1698b94584840b63e11b5a2b2                  
2022-08-02	147.35	147.35	f06ac9fd1b610d8aa41a7bf6223581fe                  
2022-08-02	90	75.63	1218474a276a0ced92adc3803e19cb39                  
2022-08-02	109.99	92.43	57ab0d552e11e3f4ead6fa758a37cfa7                  
2022-08-02	90	75.63	aed890e3c086bf1a9eda6eed52cacb51                  
2022-08-02	35	29.41	5a98c6ffd1c710444369bd15c67cfc87                  
2022-08-02	100.98	84.86	251af0490427b360c0589c38b7649f0e                  
2022-08-03	85.5	71.85	2d0ddb095dc61b5f7a760cb71cb76732                  
2022-08-03	60	50.42	769cebc4ac4cf6e81d835bfc63eba3f6                  
2022-08-03	85.5	71.85	54225ce86824da597a05192bf9a093c4                  
2022-08-03	67.5	56.72	fb305ad7e0d80627af1642cd1ac2350d                  
2022-08-03	85.5	71.85	8da0059ba097f053451a97b68f7995d5                  
2022-08-03	150.65	125.54	9ddfc0a5798f8aabafcffbd1d4f12e0e                  
2022-08-03	85.5	71.85	aa5f2af9d33b6e57fe5a09756e610baa                  
2022-08-03	0	0	ab85e3065ae320b648c9d0b2c402c777                  
2022-08-03	99	83.19	f3322796adb2454367973de02cbfc310                  
2022-08-03	85.5	71.85	53f602d286890fc5021be78e8105b2cb                  
2022-08-03	134.98	113.43	21515f919ceb41131bb8ad9d29e4271b                  
2022-08-03	109.99	92.43	15461ae9153da93cf83cdcace13ff655                  
2022-08-03	24.99	21	ad6f435c6e1e7041a986c71e216bcc76                  
2022-08-03	90	75.63	77cd880ee3ff5eb19ad3aef094963b06                  
2022-08-03	99	83.19	2fd04fde20fa83fd36a1a7b9868a6380                  
2022-08-03	60	50.42	f4be675eba1717c635cd7ef288debaaa                  
2022-08-03	14.4	12.1	d12f18126ec70571eb52ed3e28f69ce7                  
2022-08-03	90	75.63	c023e53da05c8d5baf5d88c1fcc96603                  
2022-08-03	109.99	92.43	f8e8e7231726fee3132c9dbc9fab9605                  
2022-08-03	94.99	79.82	ef0e06923a0f93127f68d9535d5f37cc                  
2022-08-04	209.99	176.46	78ed01835a2d25a48d045e8db9b0dcfd                  
2022-08-04	0	0	6b8622e04290bc45514963be63415313                  
2022-08-04	0	0	77c3a006172d5218f5f86962b8115efd                  
2022-08-04	0	0	05f4c209fb962406fc856ba45cf04738                  
2022-08-04	0	0	93a8d574a380fbf57b3153c9902fac0b                  
2022-08-04	109.99	92.43	7004aafd7f4518abc9614bf29ca0ec6e                  
2022-08-04	109.99	92.43	3bd987f3eee9eecbcbe7b5bd50211afb                  
2022-08-04	85.5	71.85	5ffbec1de1497e4d41f15a4f8554604c                  
2022-08-04	85.5	71.85	a36c35c337946efe3d7e457da2b82fb9                  
2022-08-04	0	0	ffe5eff33393de9bf4cd83ed05a27584                  
2022-08-04	230.96	194.08	1fb1dc05c44a5f4df3485cfad9775305                  
2022-08-04	0	0	1025dc4bf69d509750c0733512975c44                  
2022-08-04	99.99	84.03	04e777dedbdec659a539e3a2b0850718                  
2022-08-04	0	0	19a342d1f983a5a7ef2fc7796ded25a0                  
2022-08-04	0	0	3e8c72c4f67d0a939a01a5434e4be20d                  
2022-08-04	0	0	5dfec0f89520b0d6b55b1203376bc38e                  
2022-08-04	0	0	4969f023fb0cff7f0389a1bbdc5d794e                  
2022-08-04	0	0	949266fe313c699fc17f385186136b20                  
2022-08-04	94.99	79.82	8bb36ee2b35a6ab457db7c548132a5e6                  
2022-08-04	90	75.63	e7da29db8af8c2f959d7f36d9b7b1b0c                  
2022-08-04	119.98	100.82	c085ac1c3855745d54e52a47e2d611fc                  
2022-08-04	85.5	71.85	6cad7d95a5ecd0d5e4131845b3a15142                  
2022-08-04	99	83.19	64fde1b78cb2339d4a9eb4356a15dbe6                  
2022-08-04	90	75.63	0c44c8039dc4a7c8db601a96c2e584be                  
2022-08-04	90	75.63	2256933543a92d44aa0f02c044473961                  
2022-08-04	109.99	92.43	0a34fbb70f9f59ce96a482dab19fc0cf                  
2022-08-04	15.99	13.44	2fc252b971fbf2f5bfb3b34b6dc678b0                  
2022-08-04	85.5	71.85	365baa7512d7dc537657db617c2ccea3                  
2022-08-04	99.99	84.03	a675a0202e19860e95e665ca38d85009                  
2022-08-05	100	100	d6f9d4d22ff963e79e29ade15492127c                  
2022-08-05	15.99	13.44	3f6a2bb4be2fb4e58cfa37038e54bc9a                  
2022-08-05	10	8.4	eee49a828680286371255b94336c5c97                  
2022-08-05	109.99	92.43	ca528551a4294fe5291f46cb2bbd6c82                  
2022-08-05	94.99	79.82	47e3804b31d12d069c326690856e5256                  
2022-08-05	100	84.03	2cb24cd83d715caf20ca89e6f2f49f68                  
2022-08-05	94.99	79.82	4b18122819428cddb26f57c76983e44c                  
2022-08-05	90	75.63	f73054fa5e9f1b051f7d571e22aa26b7                  
2022-08-05	0	0	6aaeeb47f18924117361142698dde0da                  
2022-08-05	119.99	100.83	7118e31fba5d897fc312125f46abbd3c                  
2022-08-05	0	0	e907fd32865b5158c3ae86cc4a22babd                  
2022-08-05	21.25	17.86	8213f695278a207f020c3a45e41584a1                  
2022-08-05	189.98	159.64	610736d01dee1e335c3b9644aed5234f                  
2022-08-05	170.99	143.69	cbe3f7c8eeb0fe63d94e7266619846c2                  
2022-08-05	109.99	92.43	ca8435009c45586efeb41c0022052971                  
2022-08-05	0	0	cc9cdd06b3fc8b84ad4b04aaae9cf815                  
2022-08-05	113.39	95.28	fa34fcae4e6831d327e50d6c294c7b8d                  
2022-08-05	0	0	b5e7bc68d6e722ed1634b954ee0b82ee                  
2022-08-05	80	67.23	0bf82fc8f779e108aa1dc0366a18f8cb                  
2022-08-05	109.99	92.43	8ee4b37249ef259535f8874748447aab                  
2022-08-05	94.82	94.82	da56624cc14a61cd83faf9fb4ea2eca5                  
2022-08-05	108.26	108.26	160c5c5165d9dd6751b91949d7f4cc9a                  
2022-08-06	113.39	95.28	8274c865895e5db3cdfe5cd8b5279067                  
2022-08-06	54	45.38	964d0939acdf6da792de039f051ebb16                  
2022-08-06	70.5	58.75	176ab428b21d3f92d00f30b864782053                  
2022-08-06	99.99	84.03	c282991612d4df5d2ca2c89583d4eeac                  
2022-08-06	85.5	71.85	0e39807822e4f63bc1d32bbc548a5f8c                  
2022-08-06	76.49	64.28	73c3b3496d3f3b7384141084556565ab                  
2022-08-06	74.99	63.02	eb1dbb78bab0db200e57420d507ea0de                  
2022-08-06	94.99	79.82	c3e2867a02b550e24ec750af06fbf15d                  
2022-08-06	94.99	79.82	f47ad0bc3097e24970301ce2323253c3                  
2022-08-07	99	83.19	2c50970bd401186ca294d6fb48dd0b0c                  
2022-08-06	107.43	107.43	faa312df8188741c3affa032c9e6fa62                  
2022-08-07	105.78	88.15	2cae45eb8fa80ae8772431630eff178e                  
2022-08-07	94.99	79.82	b481115f4025f5e6b6a6ce0405bdf48a                  
2022-08-07	264.97	222.66	95764313f1be6c9c40ab4d1e93de801b                  
2022-08-07	99.99	84.03	6504382e86d584ba7fc6f67ca2f11673                  
2022-08-07	99.99	84.03	30df1f4de17799d30ac1d3be6c5167ec                  
2022-08-07	10	8.4	f9c857419c6b90ba64d3a9528ed2048f                  
2022-08-07	99	83.19	9c3b47439652e840e5f96915bc9ba6d8                  
2022-08-07	196.03	163.35	66f58b0d2ebcfd7722af08e95c62fdba                  
2022-08-07	219.98	184.86	57d6b06cd25a1991827934d673db177f                  
2022-08-07	170.99	143.69	8678792d5c2b96f0b9ba98ce76ce2839                  
2022-08-07	109.99	92.43	55daa7ea5011ed70e1d1797911e727ad                  
2022-08-07	109.99	92.43	4825f6a656c846e42d36fed3a58a225d                  
2022-08-07	263.07	219.22	96a600f335b409657e428be059348e4e                  
2022-08-07	0	0	47a181c2893420aef9c5baf20e2f6088                  
2022-08-07	0	0	7b97e043d05348c763fbec7a9295eb6b                  
2022-08-07	0	0	dad6672e4b7658cde8fa3f48117febc6                  
2022-08-07	85.5	71.85	dc518045d818be5dba4e003ce6deb884                  
2022-08-07	99.02	99.02	d91c03b7d92daf46d3e55b20e032b81b                  
2022-08-07	75	75	2695479f0a6fed4255207db0bc35381e                  
2022-08-07	109.99	92.43	1af49f9d4b0a99c57925a8c702b0ec0b                  
2022-08-07	109.99	92.43	e10ef6bfcbb044d13336e235f645dacd                  
2022-08-07	76	63.87	798bd8f62c3110e10081f6f22c7f0e9c                  
2022-08-07	178.99	150.41	b3336afc40747232f07a13e4c400039c                  
2022-08-07	189.98	159.64	7ee44ec2dbac12d56f7fccd7a751b92d                  
2022-08-07	96.21	80.17	8139228413f857ee682cd8f3a1ec33cf                  
2022-08-07	110.98	93.26	495e460113f1e4bf186a32d2e7a55d3a                  
2022-08-07	133.4	111.16	af9738bbf76cb5b21fef35c7baaf8594                  
2022-08-07	109.99	92.43	9c7996898568480ffc3dd85472d26a55                  
2022-08-07	94.99	79.82	12d670eee4894671a56444ba05e25a18                  
2022-08-07	85.5	71.85	f6cf87212eb2443014e6f10955729904                  
2022-08-07	204.98	172.25	1a9dadd810f98bfede9abac4667024b7                  
2022-08-07	99.99	84.03	10dd94d65977c0d68e963aa9b3dc1503                  
2022-08-07	115.83	115.83	c3e739688e923bd227f82fbfb6dab731                  
2022-08-08	115.84	115.84	2f995b5740f47a6f6b1aaa73a81d2fbc                  
2022-08-08	183.06	183.06	59bc0f5480efb74212e8f915de2a9bdb                  
2022-08-08	25	25	656edf38396560e59aab77d59d088d2a                  
2022-08-08	0	0	2ec204382f49a8d3e283ee34cb4d262c                  
2022-08-08	115.98	97.47	5d65c8613eaa2e1f14bb06d71b8bc558                  
2022-08-08	85.5	71.85	3dbc23ab9e89840c08af9ae7252fda3f                  
2022-08-08	0	0	418f2cd8aba80cb04a4274e2f78fe1db                  
2022-08-08	0	0	9808e9c4cb4c69fb216c99b1acd0882f                  
2022-08-08	51	42.86	9158c873c84b4458d48801473be4226e                  
2022-08-08	163.99	137.81	7bf399d2b8e47419f17c1ca963ca72bc                  
2022-08-08	60	50.42	f4259c66c27eabdec5bae18678cbb61f                  
2022-08-08	139.99	117.63	d64cf7ee92f0daed6a2427f33d070fa1                  
2022-08-08	0	0	aaa5a41b62921d18c87994482aa584bd                  
2022-08-05	99.99	84.03	37170b54cd9c6341a59d93480a9778a6                  
2022-08-08	0	0	c76b40d624a1e4d3a12b954d23f48c40                  
2022-08-08	0	0	708c4d67b42b051f4a02a9f075249cc0                  
2022-08-08	60	50.42	903ab841e4cd7a190251a64ad3a1f7d0                  
2022-08-08	60	50.42	35a4831df4592138157143741697f200                  
2022-08-08	110.98	93.26	b817cbe8a41d9b42e124bdea8a9d8df7                  
2022-08-08	0	0	80c2bc4aab81fabfe23b151ec38b0c56                  
2022-08-08	90	75.63	9c65d56209983b633db1966d2fbe9828                  
2022-08-08	109.83	91.52	04f0a2ba123cdcd3a439ffcd23df6914                  
2022-08-08	94.99	79.82	4f9c342550e3f83e60487b3162008921                  
2022-08-08	109.99	92.43	b11da2885481c5a887f793ebb371f1c6                  
2022-08-08	85.5	71.85	c84283d1e5e73ac57852ac1174ef3c90                  
2022-08-08	254.97	214.26	ac6e8b7b40d8a4f6d884eb5749ac90e4                  
2022-08-08	74.99	63.02	9791a19828053e297ca5b10b7197e2f8                  
2022-08-08	178.85	178.85	b1df7bb2224a8d23d42eb2cbdc608ea7                  
2022-08-02	94.99	79.82	2faf1aa4f052e22b3a2072315f84d8fa                  
2022-08-01	299.97	252.07	1650a3aeffd054bea126b003755b7443                  
2022-08-07	85.5	71.85	e98ca456b3d247858aa0aaeecb651fb9                  
2022-08-09	99.99	84.03	531e4c7b3048cff204d054f429f5a813                  
2022-08-09	94.99	79.82	6b13013834143c2b5a713d6bd8197a58                  
2022-08-09	0	0	1e78ed17594624d8f0c37301ae71d9ef                  
2022-08-09	0	0	3a1e231cfe02d7b1337bfe94797b643c                  
2022-08-09	0	0	1ef263da718f6979ec6dc84a4c41af0b                  
2022-08-09	0	0	be2acdf64bfb5d074dfc454e1c73f0d4                  
2022-08-09	0	0	dfdd017b69d1ae5c18049276c333647d                  
2022-08-09	96.21	80.17	6c57092f3115a688afa077653dfdaa55                  
2022-08-09	99.99	84.03	d4bd60f3839ce2c4ba60abb0730e9c07                  
2022-08-09	150.97	126.87	05aafb5869ef4cca7f52ab52ccc7a88d                  
2022-08-09	167.99	141.17	80f2e7b5acca6f9c108c05ee9e9e3867                  
2022-08-09	94.99	79.82	6e38a4abf6ddfd9a6b010ca690313329                  
2022-08-09	10	8.4	ba9ff84a502e56d3c60437c2230205f0                  
2022-08-09	0	0	2098db48be0b1da1510336bf888885a4                  
2022-08-09	96.21	80.17	04b02865c286355d5be579a47b1c1c61                  
2022-08-09	24.99	21	dfa57ebb3add845905337876dd0e7171                  
2022-08-09	109.99	92.43	e703600604e7bec16417c935ee597802                  
2022-08-09	99.99	84.03	e1d1d12edb578eaf2af957698d46fc65                  
2022-08-09	94.99	79.82	018f22097e0ac0dfb92f1bc8673aa5cf                  
2022-08-09	99.99	84.03	4912e46a36da7dc97b5dae112d166cb8                  
2022-08-03	94.99	79.82	797be05e39512dac457b2b6e2feb908c                  
2022-08-01	44.99	37.81	e9d494ff36c3e8b3b4c0e7a57b141824                  
2022-08-01	199.98	168.06	d93d3192a6326c7a81aff1ba8abd79bc                  
2022-08-10	99.99	84.03	027109b899582228b1468f907497469a                  
2022-08-10	170.99	143.69	3d7cff159045cb0e40173b19ed91f8b8                  
2022-08-10	94.99	79.82	a38f2c34bf2453b8f5ba22f1420a7bcb                  
2022-08-10	0	0	8c417a1c8a6392216ecdc772eed4cbcd                  
2022-08-10	0	0	b56eac66b9a4ab2d71af86c36982e925                  
2022-08-10	94.99	79.82	ae6ec4a2d7414385669138c3b143ec83                  
2022-08-10	112.52	92.23	cdb1a07e4877a7f3d88a68e9efebb552                  
2022-08-10	88	73.95	213f64c064995c81ddca06d1204ae4c7                  
2022-08-10	94.99	79.82	6f5bd61a94b41d7629f5adac7cd7a924                  
2022-08-10	99	83.19	918891ec4b482632eb6315d71e3796b0                  
2022-08-10	94.99	79.82	d26c565347d18cc902b35126ceae4a4e                  
2022-08-10	185.96	156.27	56ed058fa0f485160da952b43497adcc                  
2022-08-10	10	8.4	36ebba400c45f1b63d3a247d2223af77                  
2022-08-08	99	83.19	f251c6fa1198d1194694cb6f9c14e2b9                  
2022-08-04	94.82	94.82	ee786784e7c477d4dbaf95172c0ac5e9                  
2022-08-03	194.98	163.85	1e82f6c8dc1e69a66a4bd4352176804b                  
2022-08-07	94.99	79.82	e122ecaf73554016672ddac07a0566cf                  
2022-08-03	109.99	92.43	44e364b3896c4befc03a53a9a6329457                  
2022-08-07	67.5	56.72	f47b9fcd87314d5be616952e19a32ed8                  
2022-08-07	161.98	136.12	57478f69b6ba06d2b88bdfd52d0ccd75                  
2022-08-06	269.96	226.86	652851ff27d93d3ce01226c5d83232e4                  
2022-08-05	191.52	159.59	26d81d5765656cb08863d0e9ff6e61b3                  
2022-08-01	90	75.63	333effaafd521f2bbd140b8b4605bfad                  
2022-08-06	331.47	278.55	3058c702085ede77be5440ffafa97393                  
2022-08-02	98.74	82.28	842e3aa5504cf1df9720dd780e8075d4                  
2022-08-05	109.99	92.43	5b9759fc389ba5be84ab7ceddd53b9d7                  
2022-08-01	179.99	151.25	e8322419cfe15c70a97179bbd4925637                  
2022-08-06	74.99	63.02	95739a00daccad42b9d6d5e361139665                  
2022-08-10	84.99	71.42	c01e127c3832c473118b8f653d40566a                  
2022-08-06	299.97	252.07	22f33b000c8186a7967c2657b00e0374                  
2022-08-08	289.97	243.67	9eb7fca8a58d32e2cb155338506df423                  
2022-08-10	94.99	79.82	1b611b49e172c5c029335eda8d0bc96c                  
2022-08-07	219.98	184.86	eb3151c4948a7bc26861bc81e2195d28                  
2022-08-05	110.84	92.36	23e295c214b3411a9ed7cd5eca042f07                  
2022-08-07	409.96	344.5	ef8c50d53b7c588584effbd4c71f6228                  
2022-08-10	99.99	84.03	4f7abe322768d337bb97001ec7349335                  
2022-08-06	199.98	168.06	14dbeb10ee02e2a354f289aa548092fe                  
2022-08-04	0	0	6167176720d298408358c9f7693f6419                  
2022-08-09	134.98	113.43	d7fee8563f0c909cdd1b7f1a1c8d9926                  
2022-08-06	174.64	174.64	a2974b4ef373ef463e8ec57b2a185640                  
2022-08-07	99.99	84.03	edb2719ef9c5d071f4f0ef0f43c6c551                  
2022-08-10	189.98	159.64	6404fe3f86b38f36be2f6cd1fe7cd998                  
2022-08-07	197.99	166.37	1bfa13e05bfd4a4706d108c5903b758e                  
2022-08-05	159.97	134.43	e8e1d8e9413af082e2f2980963a6e331                  
\.


-- Completed on 2022-09-29 20:18:05

--
-- PostgreSQL database dump complete
--

