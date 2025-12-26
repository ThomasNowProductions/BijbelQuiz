-- SQL INSERT statements for en questions table
-- Generated from questions-en.json
-- Generated on: 1766784425.2406912

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000001', 'How many books does the New Testament have?', '27', ARRAY['26','66','39'], 3, 'mc', '{}', NULL)
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000002', 'What did Hannah name her child?', 'Samuel', ARRAY['Saul','Samson','Gideon'], 1, 'mc', '{}', '1 Samuel 1:20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000003', 'Who was responsible for the massacre of children in Bethlehem shortly after Jesus''s birth?', 'Herod', ARRAY['Pilate','The High Priest','Quirinius'], 1, 'mc', ARRAY['Matthew'], 'Matthew 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000004', 'Jesus healed Peter''s mother-in-law. What was wrong with her?', 'Fever', ARRAY['Paralysis','Blind in one eye','Bleeding'], 4, 'mc', '{}', 'Mark 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000005', 'What promise do the meek receive from the Lord Jesus in the Beatitudes?', 'They shall inherit the earth', ARRAY['For them is the kingdom of heaven','They shall be called children of God','They shall see God'], 3, 'mc', ARRAY['Matthew'], 'Matthew 5:5')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000006', 'What promise follows the Beatitude ''blessed are the pure in heart''?', 'they shall see God', ARRAY['For them is the kingdom of heaven','They shall be called children of God','They shall inherit the earth'], 3, 'mc', '{}', 'Matthew 5:8')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000007', 'Which prophet was not allowed to marry by the Lord?', 'Jeremiah', ARRAY['Isaiah','Ezekiel','Hosea'], 5, 'mc', ARRAY['Jeremiah'], 'Jeremiah 16:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000008', 'Which prophet was commanded to marry by the Lord?', 'Hosea', ARRAY['Isaiah','Jeremiah','Ezekiel'], 5, 'mc', ARRAY['Hosea'], 'Hosea 1:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000009', 'Which prophet and his children were a symbol for Israel?', 'Isaiah', ARRAY['Jeremiah','Ezekiel','Hosea'], 5, 'mc', ARRAY['Isaiah'], NULL)
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000010', 'Which prophet lost his wife during his time as a prophet?', 'Ezekiel', ARRAY['Isaiah','Jeremiah','Hosea'], 5, 'mc', ARRAY['Ezekiel'], 'Ezekiel 24:16-24')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000011', 'On the 1st day God created...', 'the light', ARRAY['man','plants','fish'], 1, 'fitb', ARRAY['Genesis'], 'Genesis 1:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000012', 'On the 2nd day there was separation between...', 'sea and sky', ARRAY['sea and land','light and darkness','light and land'], 1, 'fitb', ARRAY['Genesis'], 'Genesis 1:6-8')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000013', 'God rested on the...', '7th day', ARRAY['1st day','5th day','6th day'], 1, 'fitb', ARRAY['Genesis'], 'Genesis 2:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000014', 'Where was the tree of the knowledge of good and evil?', 'In the garden of Eden', ARRAY['In the garden of Aden','Just outside the garden of Eden','In Shinar'], 1, 'mc', ARRAY['Genesis'], 'Genesis 2 and 3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000015', 'Who was murdered by Cain?', 'Abel', ARRAY['His mother','His father','Esau'], 1, 'mc', ARRAY['Genesis'], NULL)
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000016', 'How old was Methuselah when he died?', '969', ARRAY['996','966','669'], 1, 'mc', ARRAY['Genesis'], 'Genesis 5:27')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000017', 'How long did Noah stay in the ark with his family?', 'Just over a year', ARRAY['40 days','7 months','1.5 years'], 3, 'mc', ARRAY['Genesis'], 'Genesis 8')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000018', 'The top of the tower of Babel was meant to reach into ...', 'the heavens', ARRAY['the clouds','great height','an invisible height'], 1, 'fitb', ARRAY['Genesis'], 'Genesis 11:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000019', 'What does the word ''Babel'' mean?', 'Confusion', ARRAY['Great city','Great tower','Destruction'], 3, 'mc', ARRAY['Genesis'], 'Genesis 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000020', 'Where was Abram born?', 'Ur of the Chaldeans', ARRAY['Canaan','Egypt','Shinar'], 1, 'mc', ARRAY['Genesis'], 'Genesis 11:26')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000021', 'What was the name of Abram''s father?', 'Terah', ARRAY['Lot','Isaac','Noah'], 3, 'mc', ARRAY['Genesis'], 'Genesis 11:26')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000022', 'Why did Abram go to Canaan?', 'God asked him to', ARRAY['There was plenty of work','Family already lived there','There was enough to eat'], 1, 'mc', ARRAY['Genesis'], 'Genesis 12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000023', 'Who was Abram''s wife?', 'Sarai', ARRAY['Rebekah','Rachel','Zilpah'], 1, 'mc', ARRAY['Genesis'], 'Genesis 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000024', 'Why did Abram and Sarai go to Egypt?', 'There was a famine in Canaan', ARRAY['There was much money to earn','They went to visit relatives','It was a command from the Lord'], 1, 'mc', ARRAY['Genesis'], 'Genesis 12:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000025', 'Abram and Lot return to Canaan. Where does Lot live?', 'In the Jordan region', ARRAY['On the coast','In the mountains','In Sodom'], 3, 'mc', ARRAY['Genesis'], 'Genesis 19')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000026', 'Sarai remains barren. Who becomes Abram''s second wife?', 'Hagar', ARRAY['Rachel','Zilpah','Bilhah'], 1, 'mc', ARRAY['Genesis'], 'Genesis 16:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000027', 'Abram and Hagar have a son, his name is...', 'Ishmael', ARRAY['Lot','Isaac','Jacob'], 1, 'fitb', ARRAY['Genesis'], 'Genesis 16:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000028', 'What did Lot''s wife do?', 'She looked back while leaving Sodom', ARRAY['She warned her husband Lot','She stayed in Sodom','She did what God asked her to do'], 1, 'mc', ARRAY['Genesis'], 'Genesis 19:26')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000029', 'Abraham and Sarah finally have a son. How old was Abraham then?', '100', ARRAY['80','90','120'], 3, 'mc', ARRAY['Genesis'], 'Genesis 21:5')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000030', 'Where should Abraham sacrifice Isaac?', 'On Mount Moriah', ARRAY['On Mount Sinai','On Mount Carmel','On Mount Horeb'], 3, 'mc', ARRAY['Genesis'], 'Genesis 22:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000031', 'Who does Isaac marry?', 'Rebekah', ARRAY['Rachel','Bilhah','Sarah'], 1, 'mc', ARRAY['Genesis'], 'Genesis 24:67')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000032', 'Who succeeds Moses?', 'Joshua', ARRAY['Aaron','Caleb','Elijah'], 1, 'mc', ARRAY['Joshua'], 'Joshua 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000033', 'Where did Moses strike the rock?', 'at Meribah', ARRAY['at Edom','at Mara','at Elim'], 3, 'mc', ARRAY['Exodus'], 'Exodus 17:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000034', 'After ... much of Canaan is conquered', '7 years', ARRAY['4 years','6 years','9 years'], 5, 'fitb', ARRAY['Joshua'], 'Joshua')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000035', 'After Joshua''s death...', 'there is no leader anymore', ARRAY['his son succeeds him','Judah succeeds him','Eleazar succeeds him'], 3, 'fitb', ARRAY['Joshua'], 'Joshua 24')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000036', 'What was Israel''s first task after Joshua''s death?', 'Fight against the remaining Canaanites', ARRAY['Finding a new leader','The people got a period of rest','Finding water sources'], 3, 'mc', ARRAY['Judges'], 'Judges 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000037', 'After a long period following Joshua''s death comes...', 'a judge', ARRAY['a king','an emperor','a prophet'], 3, 'fitb', ARRAY['Judges'], 'Judges 3:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000038', 'Who was the first judge?', 'Othniel', ARRAY['Ehud','Samgar','Barak'], 2, 'mc', ARRAY['Genesis'], 'Judges 3:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000039', 'Under the leadership of the first judge...', 'people serve God again', ARRAY['people serve the idols again','the enemy is driven away','the people become rebellious again'], 3, 'fitb', ARRAY['Judges'], 'Judges 3: 9, 10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000040', 'Who are the most well-known judges?', 'Gideon, Samson and Samuel', ARRAY['Saul, David and Solomon','Jephthah, Deborah and Barak','Othniel, Ehud and Samgar'], 1, 'mc', ARRAY['Judges'], 'Judges')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000041', 'With how many men did Gideon drive away a large army of Midianites?', '300 men', ARRAY['1000 men','100 men','500 men'], 3, 'mc', ARRAY['Judges'], 'Judges 7:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000042', 'Who was the last judge?', 'Samuel', ARRAY['Eli','Samson','Jephthah'], 1, 'mc', ARRAY['Judges'], '1 Samuel')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000043', 'Which answer does not belong. Samson may NOT ... ', 'not marry', ARRAY['not drink wine or beer','not cut his hair','not touch dead bodies'], 1, 'fitb', ARRAY['Judges'], 'Judges 13')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000044', 'Deborah defeated the ... ', 'Canaanites', ARRAY['Midianites','Ammonites','Philistines'], 5, 'fitb', ARRAY['Judges'], 'Judges 4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000045', 'Several judges are mentioned as heroes of faith in the Epistle to the Hebrews. Which judge is NOT mentioned in it?', 'Deborah', ARRAY['Gideon','Samson','Samuel'], 3, 'mc', '{}', 'Hebrews 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000046', 'Who leads the people after Samuel?', 'King Saul', ARRAY['King David','High Priest Eli','Judge Samson'], 1, 'mc', '{}', '1 Samuel 10:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000047', 'Who was the first king of Israel?', 'Saul', ARRAY['David','Solomon','Herod'], 1, 'mc', '{}', '1 Samuel 10:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000048', 'Saul is anointed by Samuel ... ', 'anointed', ARRAY['crowned','consecrated','baptized'], 1, 'fitb', ARRAY['1 Samuel'], '1 Samuel 10:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000049', 'But I hate him, because he prophesies nothing good about me, but evil. Who said that?', 'Ahab', ARRAY['Micaiah','Jezebel','Baasha'], 5, 'mc', ARRAY['1 Kings'], '1 Kings 22:8')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000050', 'In which time period does the story of Ruth take place?', 'Time of Judges', ARRAY['Time of Kings','Exile','Time of Prophets'], 3, 'mc', ARRAY['Genesis','Ruth'], NULL)
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000051', 'From which place did Elimelech and Naomi come?', 'Bethlehem', ARRAY['Jerusalem','Cana','Moab'], 3, 'mc', ARRAY['Ruth'], 'Ruth 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000052', 'What were the names of the women whom Naomi''s sons married?', 'Orpah and Ruth', ARRAY['Orpah and Rebekah','Ruth and Rachel','Ruth and Rebekah'], 1, 'mc', ARRAY['Ruth'], 'Ruth 1:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000053', 'How did Naomi want to be called?', 'Mara', ARRAY['Martha','Mary','Miriam'], 1, 'mc', ARRAY['Ruth'], 'Ruth 1:20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000054', 'Why was Boaz kind to Ruth?', 'Ruth''s devotion to Naomi touched him', ARRAY['He was in love with Ruth','Because he was related to Naomi','God asked this of him'], 3, 'mc', ARRAY['Ruth'], 'Ruth 2:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000055', 'What is a kinsman-redeemer?', 'A close relative who has the duty to help another family member', ARRAY['A close relative','A close relative who has much money','A close relative who lives in the same place'], 1, 'mc', '{}', 'Ruth 3:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000056', 'What did Boaz give as proof of his redemption?', 'His sandal', ARRAY['A clay tablet','His ring','His coat'], 3, 'mc', ARRAY['Ruth'], 'Ruth 4:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000057', 'What is the name of Boaz and Ruth''s son?', 'Obed', ARRAY['Judah','Machlon','Chilion'], 1, 'mc', ARRAY['Ruth'], 'Ruth 4:17')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000058', 'Of whom did Obed become father?', 'Jesse', ARRAY['Isaac','Ishmael','Issachar'], 1, 'mc', ARRAY['Ruth'], 'Ruth 4:17')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000059', 'Of whom did Jesse become father?', 'Of King David', ARRAY['Of King Solomon','Of King Saul','Of King Abijah'], 1, 'mc', '{}', '1 Samuel 17:12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000060', 'How many wives did Elkanah have?', 'Two', ARRAY['One','Three','Four'], 1, 'mc', ARRAY['Genesis'], '1 Samuel 1:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000061', 'What did the old priest think when Hannah prayed in the temple?', 'That she was drunk', ARRAY['That she was praying earnestly','That she was sad','That she was tired'], 1, 'mc', '{}', '1 Samuel 1:14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000062', 'What did Hannah name her son?', 'Samuel', ARRAY['Samson','Gideon','Judah'], 1, 'mc', ARRAY['Genesis'], '1 Samuel 1:20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000063', 'What does Samuel mean?', 'Asked of God', ARRAY['Man of God','Comforter','God gives'], 3, 'mc', ARRAY['1 Samuel','2 Samuel'], '1 Samuel 1:17')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000064', 'Where did Hannah bring Samuel?', 'To Eli', ARRAY['To Jerusalem','To Elijah','To the temple in Jerusalem'], 3, 'mc', ARRAY['1 Samuel'], '1 Samuel 1: 25')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000065', 'What did Hannah NOT bring with her when she brought Samuel to Eli?', '2 measures of barley', ARRAY['3 bulls','an ephah of flour','a flask of wine'], 5, 'mc', ARRAY['1 Samuel'], '1 Samuel 1:24')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000066', 'Who thought that Samuel called him?', 'Eli', ARRAY['Hophni','Phinehas','the Lord'], 1, 'mc', ARRAY['1 Samuel'], '1 Samuel 3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000067', 'Which position did Samuel NOT hold in his life?', 'King', ARRAY['Prophet','Priest','Judge'], 1, 'mc', '{}', '1 Samuel')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000068', 'How is the holy city called in Ezekiel 48?', 'The Lord is there', ARRAY['Zion','Jerusalem','City of God'], 5, 'mc', ARRAY['Ezekiel'], 'Ezekiel 48:35')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000069', 'Which psalm is often called the Shepherd''s Psalm?', 'Psalm 23', ARRAY['Psalm 1','Psalm 25','Psalm 42'], 1, 'mc', ARRAY['Psalms'], 'Psalm 23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000070', 'What do you call a male sheep?', 'A ram', ARRAY['A buck','A lamb','An ewe'], 1, 'mc', ARRAY['Genesis'], 'Genesis 22')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000071', 'On which instrument did David often play?', 'Harp', ARRAY['Harp','Flute','Cymbal'], 3, 'mc', ARRAY['1 Samuel'], '1 and 2 Samuel')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000072', 'Who wrote the biblical book of Proverbs?', 'Solomon', ARRAY['David','Asaph','Jehoshaphat'], 1, 'mc', ARRAY['Proverbs'], 'Proverbs')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000073', 'What is the beginning of wisdom?', 'The fear of the Lord', ARRAY['The knowledge of the Lord','The instruction of the Lord','The thoughtfulness of the Lord'], 3, 'mc', ARRAY['Proverbs'], 'Proverbs 1:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000074', 'What is God to those who walk uprightly?', 'A Shield', ARRAY['A Fortress','A Refuge','A High Tower'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 2:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000075', 'With what must one honor the Lord', 'With possessions', ARRAY['With prayer','With wisdom','With sincerity'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 3:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000076', 'What is more precious than rubies?', 'Wisdom', ARRAY['Love','Virtue','Knowledge'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 3: 13-15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000077', 'Who must be saved?', 'Those in danger of death', ARRAY['Those who waver','Those who wander','Those who live godlessly'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 24:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000078', 'Wisdom is like ... ?', 'a beautiful crown on the head', ARRAY['a golden necklace around the neck','an ornament of knowledge','a band of insight'], 3, 'fitb', ARRAY['Proverbs'], 'Proverbs 4:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000079', 'From where must our foot remain distant?', 'From evil', ARRAY['From the path of the wicked','From uneven paths','From paths of death'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 4:14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000080', 'How many things are an abomination to the Lord?', 'Seven', ARRAY['Five','Six','Three'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 6:16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000081', 'What covers love?', 'All transgressions', ARRAY['All greed','All unkindness','All hatred'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 10:12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000082', 'What is in the house of a righteous man?', 'A great treasure', ARRAY['Love and faithfulness','Understanding','Knowledge'], 5, 'mc', ARRAY['Proverbs'], 'Proverbs 15:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000083', 'Who will fall into a pit?', 'He who digs a pit', ARRAY['Who shoots burning arrows','Who is wise in his own eyes','Who honors a fool'], 3, 'mc', ARRAY['Proverbs'], 'Proverbs 26:27')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000084', 'When does one find mercy?', 'When one confesses and forsakes sins', ARRAY['When one is a man of understanding','When one loves in secret','When one does not harden his heart'], 3, 'mc', ARRAY['Proverbs'], 'Proverbs 28:13')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000085', 'Where did Jesus grow up?', 'Nazareth', ARRAY['Jerusalem','Bethlehem','Capernaum'], 1, 'mc', ARRAY['Matthew'], 'Matthew 2:23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000086', 'How many days was Jesus tempted by the devil:', '40 days', ARRAY['3 days','10 days','7 weeks'], 1, 'mc', '{}', 'Mark 1:13')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000087', 'On what should one build their life''s house?', 'Rock', ARRAY['Sand','A mountain','Clay ground'], 1, 'mc', '{}', 'Matthew 7:25')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000088', 'Of whom did Jesus say: I have not found such great faith even in Israel?', 'The centurion', ARRAY['Peter','The leper','The blind man'], 1, 'mc', ARRAY['Matthew'], 'Matthew 8:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000089', 'Where was Matthew when Jesus called him?', 'In the tax office', ARRAY['On the temple grounds','In a tree','In front of his house'], 3, 'mc', ARRAY['Matthew'], 'Matthew 9:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000090', 'How big must our faith be according to Jesus?', 'Like a mustard seed', ARRAY['Like a mountain','Like a rock','Like a cedar of Lebanon'], 1, 'mc', ARRAY['Matthew'], 'Matthew 17:20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000091', 'How many times must we forgive each other?', '70 x 7 times', ARRAY['7 times','3 times','always'], 1, 'mc', '{}', 'Matthew 18:22')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000092', 'Who cried out: Lord, Son of David, have mercy on us', '2 blind men', ARRAY['10 lepers','the children','the lame'], 1, 'mc', '{}', 'Matthew 20:30')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000093', 'Which tree was cursed by Jesus?', 'The fig tree', ARRAY['The olive tree','The cedar','The date palm'], 3, 'mc', '{}', 'Mark 11:21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000094', 'Who wrote the book of Revelation?', 'John', ARRAY['Paul','Peter','Matthew'], 1, 'mc', ARRAY['Revelation'], 'Revelation 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000095', 'To how many churches did John write a letter?', '7', ARRAY['6','8','5'], 1, 'mc', ARRAY['Revelation'], 'Revelation')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000096', 'What was John told to write to Ephesus?', 'You have left your first love', ARRAY['Be faithful unto death','I have given you an open door','And I will give you each according to your works'], 5, 'mc', ARRAY['Ephesians'], 'Revelation 2:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000097', 'What will Jesus give the church in Smyrna if they remain faithful?', 'The crown of life', ARRAY['A white stone','A new name','Hidden manna'], 5, 'mc', ARRAY['Revelation'], 'Revelation 2:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000098', 'To which teaching did they in Pergamum cling?', 'The teaching of Balaam', ARRAY['The teaching of the Pharisees','There is no resurrection','The teaching of Paul'], 5, 'mc', ARRAY['Revelation'], 'Revelation 2:14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000099', 'What woman did they allow in Thyatira?', 'Jezebel', ARRAY['the wife of Herod','The wife of Potiphar','Salome'], 5, 'mc', ARRAY['Revelation'], 'Revelation 2: 20-23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000100', 'For what will Jesus keep the church of Philadelphia?', 'The hour of trial', ARRAY['From poverty','From diseases','From spiritual decline'], 5, 'mc', ARRAY['Revelation'], 'Revelation 3:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000101', 'Why will Jesus spew Laodicea out of His mouth?', 'Because they are lukewarm', ARRAY['Because they are hot','Because they are cold','Because they are hard'], 3, 'mc', ARRAY['Revelation'], 'Revelation 3: 15, 16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000102', 'What was around God''s throne in Revelation?', 'A rainbow', ARRAY['A light','Golden rays','A cloud'], 5, 'mc', ARRAY['Revelation'], 'Revelation 4:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000103', 'And around the throne were thrones; and on the thrones I saw ... elders sitting, clothed in white robes, and they had golden crowns on their heads. ', '24', ARRAY['7','7 x 7','3'], 3, 'fitb', ARRAY['Revelation'], 'Revelation 4:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000104', 'What did the great multitude that no one could count have in their hands?', 'Palm branches', ARRAY['Torches','Trumpets','Bowls of incense'], 5, 'mc', ARRAY['Revelation'], 'Revelation 7:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000105', 'What does God do with the people who come out of the great tribulation?', 'God will wipe away every tear from their eyes', ARRAY['God will give them a new name','God will seal their foreheads','God will dwell among them'], 3, 'mc', ARRAY['Revelation'], 'Revelation 21:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000106', 'What happened when the third angel sounded?', 'A great star, blazing like a torch, fell from the sky', ARRAY['The smoke of incense with the prayers of the saints ascended','There became hail and fire mixed with blood','Something like a great mountain, burning with fire, was thrown into the sea'], 5, 'mc', ARRAY['Revelation'], 'Revelation 8:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000107', 'What is the name of the angel of the bottomless pit in Revelation?', 'Abaddon', ARRAY['Lucifer','The dragon','The beast'], 5, 'mc', ARRAY['Revelation'], 'Revelation 9:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000108', 'What was John told to eat in Revelation?', 'A little book', ARRAY['A honey cake','Bread','Figs'], 5, 'mc', ARRAY['Revelation'], 'Revelation 10:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000109', 'How many witnesses will prophesy for 1260 days?', '2', ARRAY['3','7','12'], 5, 'mc', ARRAY['Revelation'], 'Revelation 11: 3-12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000110', 'And the woman fled to the ... , where she had a place prepared by God', 'wilderness', ARRAY['temple','mountains','city'], 3, 'fitb', ARRAY['Revelation'], 'Revelation 12:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000111', 'How many bowls of wrath are there?', 'Seven', ARRAY['Three','Five','Four'], 5, 'mc', ARRAY['Revelation'], 'Revelation 16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000112', 'Which city comes down from heaven?', 'The new Jerusalem', ARRAY['The city of God','The city with many dwellings','That city which has foundations'], 1, 'mc', ARRAY['Revelation'], 'Revelation 21: 1-4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000113', 'What do the Spirit and the Bride say?', 'Come', ARRAY['Amen','Hallelujah','I am the Alpha and the Omega'], 1, 'mc', ARRAY['Revelation'], 'Revelation 22:17')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000114', 'How many letters are there from Paul to the Corinthians?', 'Two', ARRAY['One','Three','Four'], 1, 'mc', ARRAY['1 Corinthians','2 Corinthians'], ' 1 and 2 Corinthians')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000115', 'How many people did Jesus raise from the dead?', 'Three', ARRAY['Two','One','Four'], 3, 'mc', '{}', 'Gospels')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000116', 'For approximately how many years did Jesus preach?', 'Three', ARRAY['Two','One','Four'], 1, 'mc', '{}', 'In the Gospels')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000117', 'In which city did they drive Jesus out of town, to the edge of the mountain, to throw Him into the abyss?', 'Nazareth', ARRAY['Jerusalem','Bethlehem','Samaria'], 1, 'mc', '{}', 'Luke 4:29')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000118', 'In which city was Bartimaeus sitting by the gate begging?', 'Jericho', ARRAY['Jerusalem','Samaria','Capernaum'], 3, 'mc', '{}', 'Mark 10:46')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000119', 'To whom was it asked: Do you also understand what you are reading?', 'The Ethiopian eunuch', ARRAY['Philip','Peter','Saul'], 1, 'mc', ARRAY['Acts'], 'Acts 8:30')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000120', 'Which island did Paul and Barnabas visit on their first missionary journey?', 'Cyprus', ARRAY['Crete','Malta','Sicily'], 3, 'mc', ARRAY['Acts'], 'Acts 13:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000121', 'Which king became severely ill, a terminal illness?', 'Hezekiah', ARRAY['Ahaz','Manasseh','Jehudah'], 1, 'mc', '{}', 'Hezekiah 20:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000122', 'After fleeing from Queen Jezebel, where did Elijah flee to the cave? Which one?', 'The cave on Mount Horeb', ARRAY['The cave of Machpelah','The cave of Adullam','The caves of Zephaniah'], 3, 'mc', ARRAY['1 Kings'], '1 Kings 19')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000123', 'What did the Israelites NOT take with them from the Egyptians when they left Egypt?', 'Food', ARRAY['Gold','Silver','Clothing'], 3, 'mc', ARRAY['Exodus'], 'Exodus 3:22')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000124', 'How long was Paul imprisoned in Caesarea during the time of Felix and Festus?', '2 years', ARRAY['1.5 years','2.5 years','3 years'], 3, 'mc', ARRAY['Acts'], 'Acts')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000125', 'Which deacon was stoned in Jerusalem?', 'Stephen', ARRAY['Philip','Timon','Nicholas'], 1, 'mc', ARRAY['Acts'], 'Acts 7: 54 - 60')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000126', 'Which son wanted to push David from the throne?', 'Absalom', ARRAY['Joab','Amnon','Adonijah'], 1, 'mc', ARRAY['2 Samuel'], '2 Samuel 15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000127', 'Who were the first to visit Jesus after His birth?', 'The shepherds', ARRAY['The wise men','King Herod','Zacharias and Elizabeth'], 1, 'mc', '{}', 'Luke 2: 8-20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000128', '10 lepers were healed by Jesus. Who came back to thank Him?', 'A Samaritan', ARRAY['An Israelite','A Jew','A Tax Collector'], 1, 'mc', '{}', 'Luke 17:11-19')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000129', 'Who was king when Daniel was thrown into the lion''s den?', 'Darius', ARRAY['Nebuchadnezzar','Belshazzar','Cyrus'], 3, 'mc', ARRAY['Daniel'], 'Daniel 6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000130', 'Peter''s mother-in-law was healed of fever. In which place was this?', 'Capernaum', ARRAY['Cana','Nain','Jericho'], 3, 'mc', '{}', 'Matthew 8:14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000131', 'The inhabitants of the Ten-Tribe Kingdom were taken to ...', 'Assyria', ARRAY['Babylon','Persia','Egypt'], 3, 'fitb', ARRAY['2 Kings'], '2 Kings 17:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000132', 'From which 2 tribes did the Two-Tribe Kingdom consist?', 'Judah and Benjamin', ARRAY['Levi and Judah','Joseph and Benjamin','Judah and Levi'], 3, 'mc', ARRAY['1 Kings'], '1 Kings 12:21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000133', '3 names are for the same lake/sea. Which one doesn''t belong?', 'The Dead Sea', ARRAY['Sea of Galilee','Sea of Gennesaret','Sea of Tiberias'], 1, 'mc', '{}', NULL)
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000134', 'A new apostle was chosen instead of Judas. Who was that?', 'Matthias', ARRAY['Justus','Philip','Nathanael'], 3, 'mc', ARRAY['Acts'], 'Acts 1:26')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000135', 'What do we think of at Easter?', 'The resurrection of Jesus', ARRAY['The birth of Jesus','The death of Jesus','The ascension of Jesus'], 1, 'mc', '{}', 'Mark 16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000136', 'Daniel received a Babylonian name. Which one?', 'Belteshazzar', ARRAY['Belshazzar','Shadrach','Meshach'], 1, 'mc', ARRAY['Daniel'], 'Daniel 1:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000137', 'The blind man had to wash in ... to become seeing.', 'the pool of Siloam', ARRAY['the pool of Bethesda','the Jordan','the pool of cleansing'], 3, 'fitb', ARRAY['John'], 'John 9: 1-7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000138', 'In the battle against Egypt, king ... of Judah fell.', 'Josiah', ARRAY['Amon','Manasseh','Ahaz'], 5, 'fitb', ARRAY['2 Chronicles'], '2 Chronicles 35: 20-24')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000139', 'Where did the first Christian church arise?', 'Jerusalem', ARRAY['Antioch','Philippi','Corinth'], 3, 'mc', ARRAY['Acts'], 'Acts 2:40-41')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000140', 'Who were the third and fourth disciples of Jesus?', 'John and James', ARRAY['Simon and Andrew','Simon and James','John and Andrew'], 5, 'mc', '{}', 'Mark 1: 16-20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000141', 'Elijah, Ahab and the people went to offer on Mount ...', 'Carmel', ARRAY['Horeb','Sinai','Tabor'], 3, 'fitb', ARRAY['1 Kings'], '1 Kings 18: 20 -40')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000142', 'What is the last word in the Bible?', 'Amen', ARRAY['Come','Thanks be to God','Blessing'], 1, 'mc', ARRAY['Revelation'], 'Revelation 22:21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000143', 'Who heard a Great Voice from Heaven say: ''Behold, the tabernacle of God is with the people and He will dwell with them''?', 'John', ARRAY['Peter','James','Jesus Himself'], 5, 'mc', ARRAY['Revelation'], 'Revelation 21:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000144', 'What is the Rider on the white horse called in Revelation?', 'Faithful and True', ARRAY['Savior','Christ Jesus','Firm and certain'], 5, 'mc', ARRAY['Revelation'], 'Revelation 19:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000145', 'Complete the sentence: Woe, woe, the great city ... , the strong city', 'Babylon', ARRAY['Jericho','Jerusalem','Nineveh'], 5, 'fitb', ARRAY['Revelation'], 'Revelation 18:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000146', 'How often was the trumpet blown in Revelation?', '7 times', ARRAY['7 times 70 times','70 times','700 times'], 5, 'mc', ARRAY['Revelation'], 'Revelation 8, 9, 10, 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000147', 'How many seals are opened in Revelation?', '7', ARRAY['8','6','3'], 5, 'mc', ARRAY['Revelation'], 'Revelation 6, 7, 8')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000148', 'Who alone could open the book with the 7 seals?', 'The Lamb', ARRAY['The Rock','The beast with 7 eyes','No one'], 5, 'mc', ARRAY['Revelation'], 'Revelation 5')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000149', 'What was in the Letter of Christ to Sardis?', 'You have a name that you live, and you are dead', ARRAY['Woe to you','The rules that church had to follow','To you is Eternal Life'], 5, 'mc', ARRAY['Revelation'], 'Revelation 3:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000150', 'Where did John write the biblical book of Revelation?', 'On the island of Patmos', ARRAY['In prison','John didn''t write Revelation','In the wilderness'], 1, 'mc', ARRAY['Revelation'], 'Revelation 1:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000151', 'What did Jude warn against in his biblical book?', 'Against false teachers', ARRAY['Against the devil','Against sin','Against the world'], 3, 'mc', ARRAY['Jude'], 'Jude 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000152', 'To whom did John write his letter, 3 John?', 'Gaius', ARRAY['The church of Laodicea','To no one specific','To Diotrephes'], 5, 'mc', ARRAY['3 John'], '3 John 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000153', 'From which place did John write his letter, 2 John?', 'From Ephesus', ARRAY['From Corinth','From Asia Minor','That is unknown'], 3, 'mc', ARRAY['John'], '2 John')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000154', 'Which prophet told King Hezekiah that he had to die?', 'Isaiah', ARRAY['Jeremiah','Micah','Amos'], 3, 'mc', ARRAY['Isaiah'], 'Isaiah 38:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000155', 'From whom did Peter cut off the ear?', 'Malchus', ARRAY['Matthew','Maltus','Caiaphas'], 1, 'mc', ARRAY['John'], 'John 18:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000156', 'What did the Macedonian man ask in Paul''s dream?', '''Come over to Macedonia and help us''', ARRAY['''Come over and help us''','''Come and see''','''Come over to Macedonia and preach the gospel'''], 3, 'mc', ARRAY['Acts'], 'Acts 16:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000157', 'Which punishment did the prophet Elijah announce to King Ahab?', 'There shall be no dew or rain', ARRAY['There shall be no more rain','Famine will come','Many people will die'], 3, 'mc', ARRAY['1 Kings'], '1 Kings 17:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000158', 'Who was the father of Samuel?', 'Elkanah', ARRAY['Elihu','Elam','Jeroboam'], 1, 'mc', ARRAY['1 Samuel'], '1 Samuel 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000159', 'In which city did Paul speak about the unknown God?', 'In Athens', ARRAY['In Corinth','In Philippi','In Thyatira'], 3, 'mc', ARRAY['Acts','Romans'], 'Acts 17:23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000160', 'Who went along on Paul and Barnabas''s first missionary journey?', 'John Mark', ARRAY['Mark','John','Peter'], 3, 'mc', ARRAY['Acts'], 'Acts 13')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000161', 'Who were the sons of Zebedee?', 'James and John', ARRAY['John and Andrew','Andrew and Peter','James and Peter'], 3, 'mc', '{}', 'Mark 1: 19 , 20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000162', 'In which place was David proclaimed king?', 'Hebron', ARRAY['Jerusalem','Judah','Gilead'], 3, 'mc', ARRAY['2 Kings'], '2 Kings 2:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000163', 'Who said: ''You almost persuade me to become a Christian''?', 'King Agrippa', ARRAY['Silas','Governor Felix','King David'], 1, 'mc', ARRAY['Acts'], 'Acts 26:28')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000164', 'During the wilderness journey the water was bitter at ...', 'Mara', ARRAY['Elim','Rephidim','Kadesh Barnea'], 1, 'fitb', '{}', 'Exodus 15:23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000165', 'Which idolatry did King Jeroboam introduce?', 'The service of the golden calves', ARRAY['The service of Baal','The service of Ashtoreth','The service of the stars'], 3, 'mc', ARRAY['1 Kings'], '1 Kings 12: 25-33')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000166', 'How many missionary journeys did Paul make?', '3', ARRAY['2','4','5'], 1, 'mc', ARRAY['Acts'], 'Acts')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000167', 'On which mountain was the Ascension of Jesus?', 'Mount of Olives', ARRAY['Horeb','Moriah','Nebo'], 1, 'mc', ARRAY['Acts'], 'Acts 1: 9-12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000168', 'Where did Jesus''s mother live?', 'Nazareth', ARRAY['Bethlehem','Jerusalem','That is unknown'], 1, 'mc', ARRAY['Luke'], 'Luke 1:26')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000169', 'How many days are there between Ascension and Pentecost?', '10', ARRAY['40','3','12'], 1, 'mc', ARRAY['Pentecost','Ascension'], 'Acts 1 and 2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000170', 'Who was the first Christian to die for his faith?', 'Stephen', ARRAY['Peter','James','Philip'], 1, 'mc', ARRAY['Acts'], 'Acts 7: 54-60')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000171', 'Blessed is the man who does not ... in the counsel of the wicked', 'walk', ARRAY['walk','stand','go'], 1, 'fitb', ARRAY['Psalms'], 'Psalms 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000172', 'What was the name of Aaron''s wife?', 'Elisheba', ARRAY['Zipporah','Jehosheba','Elizabeth'], 5, 'mc', ARRAY['Exodus'], 'Exodus 6:22')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000173', 'How did the people react when the law was read aloud by Ezra?', 'They wept', ARRAY['They rejoiced','They left the city','They rebelled'], 5, 'mc', ARRAY['Nehemiah'], 'Nehemiah 8:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000174', 'What was Nehemiah''s function at the court of the king of Persia?', 'Cupbearer', ARRAY['Head of the guards','Herald','Bookkeeper'], 4, 'mc', ARRAY['Nehemiah'], 'Nehemiah 1:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000175', 'What was Ezra''s main task when he came to Jerusalem?', 'Teach the people in the Law of the Lord', ARRAY['Rebuild the city','Restore the walls','Cleanse the temple'], 5, 'mc', ARRAY['Ezra'], 'Ezra 7:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000176', 'What happened to King Uzziah when he wanted to perform the priestly office?', 'He got leprosy', ARRAY['He was blessed','He became king over all tribes','He was expelled from Jerusalem'], 5, 'mc', ARRAY['2 Chronicles'], '2 Chronicles 26: 16-21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000177', 'What did Solomon do after he completed the temple?', 'He prayed', ARRAY['He left Jerusalem','He destroyed the high places','He hid the ark'], 4, 'mc', ARRAY['1 Kings'], '1 Kings 8: 22, 23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000178', 'Who brought the ark of God to Jerusalem, after it had first failed?', 'David', ARRAY['Moses','Saul','Joab'], 3, 'mc', '{}', '2 Samuel 6: 12-15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000179', 'What did Elisha do to make the bitter water of Jericho healthy?', 'He threw salt into the spring', ARRAY['He prayed to God','He struck the water with his cloak','He commanded the water to stand still'], 4, 'mc', ARRAY['2 Kings'], '2 Kings 2:21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000180', 'What happened at the dedication of the temple that Solomon built?', 'The cloud filled the house of the Lord', ARRAY['Fire came from heaven','The ark disappeared','The priests went into the sanctuary'], 4, 'mc', ARRAY['1 Kings'], '1 Kings 8: 10, 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000181', 'What did David do when he heard of the death of Absalom?', 'He wept and mourned', ARRAY['He celebrated','He fled','He stoned himself'], 2, 'mc', ARRAY['2 Samuel'], '2 Samuel 18:33')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000182', 'With how many men did Gideon defeat the army of Midian?', '300', ARRAY['30','1000','3000'], 2, 'mc', ARRAY['Judges'], 'Judges 7:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000183', 'Who was the only female judge of Israel?', 'Deborah', ARRAY['Hannah','Ruth','Jael'], 1, 'mc', ARRAY['Judges'], 'Judges 4:4-5')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000184', 'What did Joshua say to the people in his farewell speech?', 'But as for me and my house, we will serve the Lord', ARRAY['Leave this land, for it is unclean','Seek for yourself another god this day','Let us return to Egypt'], 2, 'mc', ARRAY['Joshua'], 'Joshua 24:15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000185', 'What did Moses have to do to get water from the rock at Meribah?', 'Strike the rock with his staff', ARRAY['Speak to the rock','Pray to the Lord','Sprinkle the rock with blood'], 3, 'mc', ARRAY['Genesis','Exodus'], 'Exodus 17:1-7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000186', 'What did the priest have to do with the blood of the guilt offering?', 'Put it on the horns of the altar', ARRAY['Put it on the ark','Put it on the west side of the sanctuary of the holy ones','Mix it with incense'], 3, 'mc', ARRAY['Exodus'], 'Exodus 29:12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000187', 'What did God say to Moses from the burning bush?', 'I am the God of your fathers', ARRAY['Go to Nineveh','You are chosen above all nations','I am your God'], 4, 'mc', ARRAY['Genesis','Exodus'], 'Exodus 3:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000188', 'What did Noah build first after the flood?', 'An altar', ARRAY['A city','A ship','A tower'], 1, 'mc', ARRAY['Genesis'], 'Genesis 8:20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000189', 'What did God say to the serpent after the fall of Adam and Eve?', '"Cursed are you above all livestock"', ARRAY['"You shall return to dust"','"You shall leave your wife"','"I will be gracious to you"'], 2, 'mc', ARRAY['Genesis'], 'Genesis 3:14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000190', 'What was the name of the disciple Matthew first?', 'Levi', ARRAY['Simon','Mark','Lazarus'], 1, 'mc', ARRAY['Matthew'], 'Mark 9:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000191', 'With whom did Mary, the mother of the Lord Jesus, live after Jesus'' death?', 'With John', ARRAY['With Martha','With Peter','With her sister'], 2, 'mc', ARRAY['John'], 'John 19: 26, 27')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000192', 'Where was the Lord Jesus led by the Spirit after his baptism in the Jordan?', 'Into the wilderness', ARRAY['To Galilee','To Capernaum','To his disciples'], 2, 'mc', ARRAY['Matthew'], 'Matthew 4 : 1-3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000193', 'How does the Sermon on the Mount begin in Matthew 5?', 'With the Beatitudes', ARRAY['With the Lord''s Prayer','With the parables of the seed','With the commandment of love'], 3, 'mc', ARRAY['Matthew'], 'Matthew 5: 1-12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000194', 'What is the first miracle of Jesus, mentioned in the biblical book of Mark?', 'Casting out an unclean spirit', ARRAY['Turning water into wine','Peter walks on the water','Jesus calms the storm'], 4, 'mc', ARRAY['Matthew','Mark','Luke'], 'Mark 1:21-28')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000195', 'Who is first mentioned in Matthew in the genealogy of Jesus?', 'Abraham', ARRAY['Jacob','Adam','Moses'], 3, 'mc', ARRAY['Matthew'], 'Matthew 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000196', 'What was the first message that Jesus preached in Mark 1?', 'Repent and believe the Gospel', ARRAY['Love one another','Go into the whole world','Watch and pray'], 4, 'mc', '{}', 'Mark 1:15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000197', 'To whom is the Gospel of Luke addressed?', 'Theophilus', ARRAY['Timothy','Titus','Silas'], 2, 'mc', ARRAY['Luke'], 'Luke 1:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000198', 'Who saw Jesus first after His resurrection?', 'The Emmaus travelers', ARRAY['Peter','Mary Magdalene','John'], 2, 'mc', ARRAY['Luke'], 'Luke 24:15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000199', 'Where does the biblical book of Luke end?', 'At the ascension of Jesus', ARRAY['At the crucifixion','At Pentecost in Jerusalem','At the announcement of the second coming'], 3, 'mc', '{}', 'Luke 24: 50-53')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000200', 'With what words does John 1 begin?', 'In the beginning was the Word', ARRAY['In the beginning God created','And it came to pass','This is the book of generations'], 2, 'mc', '{}', 'John 1: 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000201', 'Who was the woman at the well?', 'A Samaritan woman', ARRAY['A Jewess','A Roman woman','A Philistine woman'], 1, 'mc', ARRAY['John'], 'John 4:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000202', 'Who took the place of Judas as apostle?', 'Matthias', ARRAY['Barnabas','Paul','Silas'], 3, 'mc', ARRAY['Acts'], 'Acts 1: 15-26')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000203', 'What did Peter do after Pentecost?', 'He preached', ARRAY['He was silent','He prayed in silence','He fled'], 1, 'mc', ARRAY['Acts'], 'Acts 2:14-41')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000204', 'Who converted on the road to Damascus?', 'Saul', ARRAY['Peter','Barnabas','Timothy'], 1, 'mc', ARRAY['Acts'], 'Acts 9: 1-6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000205', 'How does the book of Acts end?', 'With Paul''s stay in Rome', ARRAY['With Paul''s death','With the destruction of Jerusalem','With Pentecost'], 4, 'mc', ARRAY['Acts'], 'Acts 28')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000206', 'How does Paul describe himself in Romans 1:1?', 'A servant of Jesus Christ', ARRAY['A prophet of Jesus Christ','A servant of men','An apostle of John'], 2, 'mc', ARRAY['Romans'], 'Romans 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000207', 'Who are the true children of Abraham?', 'Those who are of faith', ARRAY['Those who are of the Spirit','Those born in Israel','Those who are of the flesh'], 2, 'mc', ARRAY['Romans'], 'Romans 4:16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000208', 'What does Paul say that we must do with our bodies?', 'Present them as a living, holy and pleasing sacrifice to God', ARRAY['Subject them to the law','Use them for good works','Offer them as sacrifices'], 4, 'mc', ARRAY['Romans'], 'Romans 12: 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000209', 'What is the summary of the law?', 'Love', ARRAY['Faith','Obedience','Hope'], 1, 'mc', ARRAY['Romans'], 'Romans 13: 8-14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000210', 'What is the problem in the church at Corinth?', 'Strife and division', ARRAY['Persecution','Lack of faith','Lack of love'], 4, 'mc', ARRAY['1 Corinthians'], '1 Corinthians 1:10-13')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000211', 'What is the body of a believer?', 'A temple of the Holy Spirit', ARRAY['Dust of the earth','A sinful vessel','A temporary tent'], 2, 'mc', ARRAY['1 Corinthians'], '1 Corinthians 6 and 20')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000212', 'How many letters did Paul write to the Corinthians that have been preserved?', 'Two', ARRAY['One','Three','Four'], 1, 'mc', ARRAY['1 Corinthians'], NULL)
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000213', 'What does Paul say about weakness?', 'My power is made perfect in weakness', ARRAY['Weakness is a sin','Avoid weakness at all times','Faith overcomes weakness'], 2, 'mc', ARRAY['2 Corinthians'], '2 Corinthians 12:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000214', 'What is the ministry that God has given to us?', 'Ministry of reconciliation', ARRAY['Ministry of judgment','Ministry of grace','Ministry of the commandments'], 2, 'mc', ARRAY['2 Corinthians'], '2 Corinthians 5:18')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000215', 'What surprises Paul?', 'That they quickly turn to another gospel', ARRAY['That the Galatians are devout','That they fast much','That they pray much'], 3, 'mc', '{}', 'Galatians 1:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000216', 'What does Paul say about the law?', 'It is a tutor to Christ', ARRAY['It justifies','It leads away from sins','It is fulfilled in Christ'], 4, 'mc', ARRAY['Galatians'], 'Galatians 3:24')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000217', 'Through what are we made righteous?', 'Through faith, by grace', ARRAY['Through the works of the law','Through keeping the law','Through prayer and fasting'], 2, 'mc', ARRAY['Galatians'], 'Galatians 2:16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000218', 'What must children do?', 'Be obedient to their parents', ARRAY['Be silent','Work','Pray'], 1, 'mc', '{}', 'Ephesians 6:1-3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000219', 'What is life for Paul?', 'Christ', ARRAY['Suffering','Struggle','Hope'], 2, 'mc', ARRAY['Philippians'], 'Philippians 1:21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000220', 'Who is mentioned as Paul''s brother and fellow worker?', 'Epaphroditus', ARRAY['Barnabas','Silas','Timothy'], 4, 'mc', ARRAY['Philippians'], 'Philippians 2:25')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000221', 'Who wrote the letter to the Colossians?', 'Paul', ARRAY['Colossians','Silas','Timotheus'], 1, 'mc', ARRAY['Colossians'], 'Colossians 1:1-2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000222', 'Who wrote the letter to the Thessalonians?', 'Paul, Silvanus and Timothy', ARRAY['Paul','Paul and Timothy','Paul and Barnabas'], 5, 'mc', '{}', '1 Thessalonians 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000223', 'What did Christ do that it was done?', 'The angel of the Lord', ARRAY['Moses','The angel of the Lord','The Holy Spirit'], 3, 'mc', ARRAY['Colossians'], 'Colossians 1:15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000224', 'What happens to the dead in Christ at His coming?', 'They shall rise first', ARRAY['They shall be judged','They return with Jesus','They shall rise last'], 2, 'mc', '{}', '1 Thessalonians 4:16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000225', 'What must happen first before the day of the Lord comes?', 'The falling away from the faith and the revealing of the man of sin', ARRAY['The coming','The resurrection from the dead','The oppression'], 3, 'mc', '{}', '2 Thessalonians 2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000226', 'How is the "man of sin" also called?', 'The son of perdition', ARRAY['The antichrist','The dragon','The ruler of darkness'], 3, 'mc', '{}', '2 Thessalonians 2:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000227', 'What is Paul''s blessing at the end of Thessalonians?', 'The grace of our Lord Jesus Christ be with you all. Amen.', ARRAY['Grace and peace be with you all. Amen.','The love of God and the fellowship of the Holy Spirit be with you all, Amen.','The peace of God be with you all. Amen.'], 4, 'mc', '{}', '2 Thessalonians 3:18')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000228', 'What does Paul say about women in the worship service?', 'That they should be in silence', ARRAY['That they should prophesy','That they should teach the people','That they should preach to the people'], 3, 'mc', '{}', '1 Timothy 2:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000229', 'What is God not?', 'A spirit of fear', ARRAY['A consuming fire','A God of judgment','A God of strife'], 4, 'mc', '{}', '2 Timothy 1:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000230', 'Which parable does Paul use for the life of a believer?', 'Soldier, athlete, farmer', ARRAY['Prophet, priest, king','Redemption, pilgrimage, traveler','Fisherman, farmer, soldier'], 5, 'mc', ARRAY['2 Timothy'], '2 Timothy 2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000231', 'Who has Paul left, having loved the present world?', 'Demas', ARRAY['Timothy'], 4, 'mc', ARRAY['Romans'], '2 Timothy 4:10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000232', 'What did Titus have to do on Crete?', 'Appoint elders in every city', ARRAY['Convince the Romans','Appoint deacons in every city','Establish a church'], 4, 'mc', ARRAY['Titus'], 'Titus 1:5')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000233', 'What does Paul say about the saving grace of God?', 'It has appeared to all men', ARRAY['It has come to Israel','It has come for the chosen ones','It teaches us to know Christ through the law'], 5, 'mc', ARRAY['Titus'], 'Titus 2:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000234', 'Who was Onesimus?', 'A runaway slave', ARRAY['A Roman soldier','An elder','A deacon'], 3, 'mc', ARRAY['Philemon'], 'Philemon 1:16')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000235', 'Who was Melchizedek?', 'A priest without genealogy', ARRAY['A priest from the line of David','A descendant of Abraham','A descendant of Moses'], 3, 'mc', ARRAY['Hebrews'], 'Hebrews 7:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000236', 'Who are mentioned in Hebrews 11 as examples of faith?', 'Noah, Abraham, Moses', ARRAY['David, Elijah, Isaiah','John, Peter, Andrew','Paul, Timothy, Titus'], 2, 'mc', ARRAY['Hebrews'], 'Hebrews 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000237', 'What is the origin of reconciliation?', 'Self-will', ARRAY['The devil','The self-will','The world'], 2, 'mc', ARRAY['James'], 'James 1:14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000238', 'Who must pray for the sick?', 'The elders of the church', ARRAY['The deacons of the church','The preachers of the church','The believing physicians from the church'], 3, 'mc', ARRAY['James'], 'James 5:14-15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000239', 'God created the heaven and earth in six days', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Genesis'], 'Genesis 2:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000240', 'Cain killed his brother Abel', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Genesis'], 'Genesis 4:8')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000241', 'Aaron was the father of Moses', 'Not true', ARRAY['True'], 1, 'tf', '{}', 'Exodus 6:19')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000242', 'The law of the jubilee year is set out in Leviticus', 'True', ARRAY['Not true'], 3, 'tf', ARRAY['Leviticus'], 'Leviticus 25: 8-55')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000243', 'Leviticus is primarily addressed to the tribe of Judah', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Leviticus'], 'Leviticus')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000244', 'Balaam''s donkey spoke to him', 'True', ARRAY['Not true'], 1, 'tf', ARRAY['Numbers'], 'Numbers 22:28')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000245', 'Deuteronomy means "restoration of the law"', 'True', ARRAY['Not true'], 4, 'tf', ARRAY['Deuteronomy'], 'Deuteronomy')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000246', 'Deuteronomy describes Moses'' last speech', 'True', ARRAY['Not true'], 3, 'tf', ARRAY['Deuteronomy'], 'Deuteronomy 32 and 33')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000247', 'Joshua was the nephew of Nun', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Joshua'], 'Joshua 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000248', 'The sun stood still during a battle under Joshua''s leadership', 'True', ARRAY['Not true'], 3, 'tf', ARRAY['Joshua'], 'Joshua 10:12-14')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000249', 'The book Joshua ends with the death of Moses', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Joshua'], 'Joshua 24')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000250', 'The book Judges ends with the words: ''In those days there was no king in Israel, everyone did what was right in his eyes''', 'True', ARRAY['Not true'], 4, 'tf', ARRAY['Judges'], 'Judges 21')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000251', 'Samson was a judge in Israel', 'True', ARRAY['Not true'], 3, 'tf', ARRAY['Judges'], 'Judges 13')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000252', 'Ruth became the grandmother of King Solomon', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Ruth'], 'Ruth 4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000253', 'Samuel was raised in the holiness in Jerusalem', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['1 Samuel'], '1 Samuel 1:3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000254', 'Saul was the first king of Israel', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Genesis'], '1 Samuel 10:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000255', 'Uzzah died when he touched the ark of God', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Exodus'], '2 Samuel 6:6, 7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000256', 'Absalom, David''s son, rose in rebellion against David', 'True', ARRAY['Not true'], 1, 'tf', ARRAY['2 Samuel'], '2 Samuel 13 - 18')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000257', 'Elijah slaughtered the Baal priests on Mount Carmel', 'True', ARRAY['Not true'], 2, 'tf', ARRAY['Genesis'], '1 Kings 18')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000258', 'After Solomon the kingdom remained intact', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['1 Kings'], '1 Kings 12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000259', 'Elisha received a double portion of Elijah''s spirit', 'True', ARRAY['Not true'], 4, 'tf', ARRAY['Revelation'], '2 Kings 2:9, 10')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000260', 'David brought the ark to Jerusalem', 'Not true', ARRAY['True'], 3, 'tf', '{}', '1 Chronicles 15')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000261', 'David built the temple in Jerusalem', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['2 Chronicles'], '2 Chronicles 2:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000262', 'Josiah found the book of the law in the temple', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['1 Chronicles'], '2 Chronicles 34')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000263', 'Cyrus was the king of the Medes', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Daniel'], 'Ezra 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000264', 'Ezra led the first group of exiles back to Jerusalem', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Ezra'], 'Ezra 2:1, 2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000265', 'Ezra was a priest and scribe', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Ezra'], 'Ezra 7:6, 11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000266', 'The temple was rebuilt during the time of Ezra', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Ezra'], 'Ezra 5 and 6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000267', 'The rebuilding of the temple was never completed', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Ezra'], 'Ezra 4: 1-5')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000268', 'Nehemiah was cupbearer to the court of the king of Babylon', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Nehemiah'], 'Nehemiah 1:11')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000269', 'Nehemiah led the rebuilding of the walls of Jerusalem', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Nehemiah'], 'Nehemiah 2 and 18')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000270', 'Mordecai was the father of Esther', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Esther'], 'Esther 2:7')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000271', 'The book Esther never mentions the name of God', 'True', ARRAY['Not true'], 1, 'tf', ARRAY['Esther'], 'Esther 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000272', 'Job was a rich man from the land of Uz', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Job'], 'Job 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000273', 'The wife of Job said: ''Bless God and die''', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Job'], 'Job 2:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000274', 'The Psalms contain both praises and complaints', 'True', ARRAY['Not true'], 1, 'tf', ARRAY['Psalms'], 'Psalms')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000275', 'David was the writer of the Biblical book Psalms', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Psalms'], 'Psalms')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000276', 'Solomon is the most important writer of the Biblical book Proverbs', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Proverbs'], 'Proverbs 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000277', 'Wickedness does the monkey tricks', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Proverbs'], 'Proverbs')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000278', 'Prophet is addressed to Solomon', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Proverbs'], 'Proverbs 1:1 and 12')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000279', 'False teachers are deceiving', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Proverbs'], 'Proverbs')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000280', 'The king has made a chariot of wood from Jerusalem', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Haggai'], 'Haggai 3:9')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000281', 'Draw me, we will leave you', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Haggai'], 'Haggai 1:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000282', 'Isaiah prophesied about the coming of the Messiah', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Isaiah'], 'Isaiah 7, 9, 11, 53')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000283', 'The Bible Isaiah has 66 chapters', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Isaiah'], 'Isaiah 66')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000284', 'Jeremiah wrote a book to the exiles in Babylon', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Jeremiah'], 'Jeremiah 29:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000285', 'Jeremiah says: Ah, LORD GOD, behold, I cannot speak', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Jeremiah'], 'Jeremiah 1:6')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000286', 'Lamentations was written after the destruction of Jerusalem', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Lamentations'], 'Lamentations 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000287', 'In Lamentations comes no single hope for you', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Lamentations'], 'Lamentations 3: 21-23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000288', 'Ezekiel prophesied in Babylon, went from Jerusalem', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Ezekiel'], 'Ezekiel 1:1-3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000289', 'Ezekiel ends with: and I was already there', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Ezekiel'], 'Ezekiel 48:35')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000290', 'Daniel worked at the court of former kings in Babylon', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Daniel'], 'Daniel')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000291', 'King Nebuchadnezzar made a statue of gold, the height was 60 cubits', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Daniel'], 'Daniel 3:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000292', 'Hosea called the people to return to the Lord', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Hosea'], 'Hosea 6:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000293', 'Hosea preached only about love and forgiveness', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Hosea'], 'Hosea')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000294', 'Joel describes a plague as judgment', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Joel'], 'Joel 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000295', 'Egypt and Edom will be saved, despite that they have turned against God', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Joel'], 'Joel 3:19')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000296', 'Amos was a shepherd from Tekoa', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Amos'], 'Amos 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000297', 'Amos saw in a vision a basket of summer fruit', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Amos'], 'Amos 8:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000298', 'Obadiah is the shortest Bible book from the Old Testament', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Obadiah'], 'Obadiah 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000299', 'Obadiah''s prophecy is directed against Israel', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Obadiah'], 'Obadiah 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000300', 'Jonah was happy with God''s compassion for Nineveh', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Jonah'], 'Jonah 4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000301', 'Jonah was swallowed by God to go to Nineveh', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Jonah'], 'Jonah 1:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000302', 'Micah foretold the birthplace of the Messiah', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Micah'], 'Micah 5:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000303', 'Micah lived in the time of King Ahab', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Micah'], 'Micah 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000304', 'Nahum prophesied against the city Nineveh', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Nahum'], 'Nahum 1, 2, 3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000305', 'In Nahum it says: four your times, O Jerusalem, pay your vows', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Nahum'], 'Nahum')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000306', 'Habakkuk says: "the righteous shall live by his faith"', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Habakkuk'], 'Habakkuk 2:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000307', 'Habakkuk is shaken by God because of his doubts', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Habakkuk'], 'Habakkuk')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000308', 'Zephaniah prophesied about the overthrow of Jerusalem', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Zephaniah'], 'Zephaniah 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000309', 'In Zephaniah comes no single hope for you', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Zephaniah'], 'Zephaniah 3: 21-23')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000310', 'Ezekiel prophesied in Babylon, went from Jerusalem', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Ezekiel'], 'Ezekiel 1:1-3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000311', 'Ezekiel ends with: and I was already there', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Ezekiel'], 'Ezekiel 48:35')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000312', 'Daniel worked at the court of former kings in Babylon', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Daniel'], 'Daniel')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000313', 'King Nebuchadnezzar made a statue of gold, the height was 60 cubits', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Daniel'], 'Daniel 3:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000314', 'Hosea called the people to return to the Lord', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Hosea'], 'Hosea 6:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000315', 'Hosea preached only about love and forgiveness', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Hosea'], 'Hosea')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000316', 'Joel describes a plague as judgment', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Joel'], 'Joel 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000317', 'Egypt and Edom will be saved, despite that they have turned against God', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Joel'], 'Joel 3:19')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000318', 'Amos was a shepherd from Tekoa', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Amos'], 'Amos 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000319', 'Amos saw in a vision a basket of summer fruit', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Amos'], 'Amos 8:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000320', 'Obadiah is the shortest Bible book from the Old Testament', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Obadiah'], 'Obadiah 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000321', 'Obadiah''s prophecy is directed against Israel', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Obadiah'], 'Obadiah 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000322', 'Jonah was happy with God''s compassion for Nineveh', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Jonah'], 'Jonah 4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000323', 'Jonah was swallowed by God to go to Nineveh', 'Not true', ARRAY['True'], 1, 'tf', ARRAY['Jonah'], 'Jonah 1:2')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000324', 'Micah foretold the birthplace of the Messiah', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Micah'], 'Micah 5:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000325', 'Micah lived in the time of King Ahab', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Micah'], 'Micah 1:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000326', 'Nahum prophesied against the city Nineveh', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Nahum'], 'Nahum 1, 2, 3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000327', 'In Nahum it says: four your times, O Jerusalem, pay your vows', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Nahum'], 'Nahum')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000328', 'Habakkuk says: "the righteous shall live by his faith"', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Habakkuk'], 'Habakkuk 2:4')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000329', 'Habakkuk is shaken by God because of his doubts', 'Not true', ARRAY['True'], 4, 'tf', ARRAY['Habakkuk'], 'Habakkuk')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000330', 'Zephaniah prophesied about the overthrow of Jerusalem', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Zephaniah'], 'Zephaniah 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000331', 'Zephaniah was written after the destruction of Jerusalem', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Zephaniah'], 'Zephaniah 1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000332', 'Ezekiel prophesied in Babylon, went from Jerusalem', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Ezekiel'], 'Ezekiel 1:1-3')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000333', 'Ezekiel ends with: and I was already there', 'Not true', ARRAY['True'], 5, 'tf', ARRAY['Ezekiel'], 'Ezekiel 48:35')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000334', 'Daniel worked at the court of former kings in Babylon', 'Not true', ARRAY['True'], 2, 'tf', ARRAY['Daniel'], 'Daniel')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

INSERT INTO questions_en (id, question, correct_answer, incorrect_answers, difficulty, type, categories, biblical_reference)
VALUES ('000335', 'King Nebuchadnezzar made a statue of gold, the height was 60 cubits', 'Not true', ARRAY['True'], 3, 'tf', ARRAY['Daniel'], 'Daniel 3:1')
ON CONFLICT (id) DO UPDATE SET
    question = EXCLUDED.question,
    correct_answer = EXCLUDED.correct_answer,
    incorrect_answers = EXCLUDED.incorrect_answers,
    difficulty = EXCLUDED.difficulty,
    type = EXCLUDED.type,
    categories = EXCLUDED.categories,
    biblical_reference = EXCLUDED.biblical_reference,
    updated_at = NOW();

-- Total questions processed: 335