--
-- PostgreSQL database dump
--

-- Started on 2009-09-07 11:43:40 EDT

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 1786 (class 0 OID 0)
-- Dependencies: 1501
-- Name: news_taggings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: da01
--

SELECT pg_catalog.setval('news_taggings_id_seq', 327, false);


--
-- TOC entry 1783 (class 0 OID 37029)
-- Dependencies: 1502
-- Data for Name: news_taggings; Type: TABLE DATA; Schema: public; Owner: da01
--

COPY news_taggings (id, model_id, tag_id) FROM stdin;
1	1	169
2	6	173
3	6	174
4	8	171
5	8	172
6	9	171
7	9	172
8	5	167
9	5	168
10	5	175
11	13	172
12	13	175
13	30	175
14	14	172
15	42	171
16	20	171
17	46	171
18	17	173
19	17	175
20	16	171
21	16	172
22	40	168
23	40	175
24	51	167
25	51	168
26	51	175
27	52	167
28	52	168
29	35	168
30	15	167
31	15	172
32	37	171
33	45	171
34	45	172
35	39	168
36	49	168
37	43	171
38	47	171
39	47	172
40	36	168
41	53	168
42	41	171
43	64	172
44	56	171
45	57	173
46	33	168
47	58	171
48	61	168
49	59	171
50	59	172
51	62	167
52	62	168
53	63	167
54	63	168
55	68	174
56	65	169
57	69	172
58	55	168
59	66	173
60	66	175
61	67	170
62	67	171
63	71	172
64	70	170
65	73	169
66	73	172
67	77	168
68	77	174
69	72	170
70	72	172
71	78	168
72	78	169
73	74	169
74	76	168
75	75	170
76	75	171
77	79	168
78	44	171
79	60	168
80	32	168
81	81	168
82	82	168
83	83	167
84	83	168
85	80	168
86	85	168
87	86	168
88	86	170
89	87	174
90	88	170
91	88	174
92	90	173
93	91	168
94	92	173
95	92	175
96	93	170
97	94	171
98	54	167
99	50	168
100	50	170
101	50	175
102	48	171
103	31	167
104	95	168
105	96	174
106	97	168
107	28	167
108	22	168
109	7	171
110	18	168
111	12	168
112	10	167
113	34	168
114	26	168
115	25	168
116	25	172
117	25	173
118	29	170
119	98	171
120	24	171
121	11	171
122	21	168
123	23	168
124	101	168
125	102	167
126	103	168
127	103	170
128	104	169
129	105	168
130	106	168
131	38	168
132	4	168
133	4	175
134	84	168
135	84	170
136	100	168
137	27	170
138	27	174
139	3	168
140	3	175
141	107	167
142	108	168
143	109	168
144	111	168
145	112	168
146	113	168
147	114	168
148	116	170
149	117	170
150	118	168
151	119	168
152	119	175
153	120	167
154	120	168
155	115	167
156	110	167
157	121	168
158	122	167
159	123	168
160	124	169
161	125	168
162	89	175
163	126	168
164	127	169
165	128	170
166	129	168
167	130	167
168	131	169
169	132	175
170	133	170
171	134	167
172	134	174
173	134	175
174	135	167
175	136	174
176	19	175
177	137	174
178	138	168
179	140	170
180	140	174
181	141	174
182	142	174
183	143	167
184	139	172
185	1	176
186	3	176
187	4	176
188	5	176
189	6	176
190	7	176
191	8	176
192	9	176
193	10	176
194	11	176
195	12	176
196	13	176
197	14	176
198	15	176
199	16	176
200	17	176
201	18	176
202	19	176
203	20	176
204	21	176
205	22	176
206	23	176
207	24	176
208	25	176
209	26	176
210	27	176
211	28	176
212	29	176
213	30	176
214	31	176
215	32	176
216	33	176
217	34	176
218	35	176
219	36	176
220	37	176
221	38	176
222	39	176
223	40	176
224	41	176
225	42	176
226	43	176
227	44	176
228	45	176
229	46	176
230	47	176
231	48	176
232	49	176
233	50	176
234	51	176
235	52	176
236	53	176
237	54	176
238	55	176
239	56	176
240	57	176
241	58	176
242	59	176
243	60	176
244	61	176
245	62	176
246	63	176
247	64	176
248	65	176
249	66	176
250	67	176
251	68	176
252	69	176
253	70	176
254	71	176
255	72	176
256	73	176
257	74	176
258	75	176
259	76	176
260	77	176
261	78	176
262	79	176
263	80	176
264	81	176
265	82	176
266	83	176
267	84	176
268	85	176
269	86	176
270	87	176
271	88	176
272	89	176
273	90	176
274	91	176
275	92	176
276	93	176
277	94	176
278	95	176
279	96	176
280	97	176
281	98	176
282	99	176
283	100	176
284	101	176
285	102	176
286	103	176
287	104	176
288	105	176
289	106	176
290	107	176
291	108	176
292	109	176
293	110	176
294	111	176
295	112	176
296	113	176
297	114	176
298	115	176
299	116	176
300	117	176
301	118	176
302	119	176
303	120	176
304	121	176
305	122	176
306	123	176
307	124	176
308	125	176
309	126	176
310	127	176
311	128	176
312	129	176
313	130	176
314	131	176
315	132	176
316	133	176
317	134	176
318	135	176
319	136	176
320	137	176
321	138	176
322	139	176
323	140	176
324	141	176
325	142	176
326	143	176
\.


-- Completed on 2009-09-07 11:43:40 EDT

--
-- PostgreSQL database dump complete
--

