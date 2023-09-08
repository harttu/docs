
// Luodaan solmut
CREATE (w:Wine {id: 0, name: 'Prancing Wolf Ice Wine 2007'})
CREATE (m:Magazine {id: 1, name: 'Wine Expert Monthly'})
CREATE (g:Grape {id: 2, name: 'riesling'})

// Luodaan linkit
CREATE (m)-[:REPORTED_ON]->(w)
CREATE (w)-[:GRAPE_TYPE]->(g)

// Lisätään viinejä
CREATE (pwolf:Winery {name: 'Prancing Wolf Winery'})
CREATE (wolfspat:Wine {name:'Prancing Wolf Spatlese 2007'})
CREATE (wolfkab:Wine {name:'Prancing Wolf Kabinett 2007'} )

// linkit tuottajan ja viinien väliin
CREATE (pwolf)-[:PRODUCED]->(wolfspat)
CREATE (pwolf)-[:PRODUCED]->(wolfkab)

// luodaan tyyppejä
CREATE (patty:person {name :"Patty"})
CREATE (tom:person {name:"Tom"})
CREATE (alice:person {name:"Alice"})

// Luodaan kaverisuhteet
CREATE (patty)-[:FRIENDS]->(tom)
CREATE (patty)-[:FRIENDS]->(alice)

// luodaan tykkäämissuhteet
match (patty:person {name:"Patty"})
match (alice:person {name:"Alice"})
match (tom:person {name:"Tom"})
match (wine:Wine {name:"Prancing Wolf Ice Wine 2007"})
match (kabi:Wine {name:"Prancing Wolf Kabinett 2007"})

CREATE (alice)-[:LIKES]->(wine)
CREATE (tom)-[:LIKES]->(kabi)

// noodien poistamisesta
// id:n avulla
// tuplanoodien poistaminen tehdään limitillä
MATCH (g {id:2})
MATCH (w {id:0})
MATCH (w)-[:GRAPE_TYPE]->(g) as d
detach delete d;

MATCH (w:Winery)-[d:PRODUCED]->(g {id:0})
WITH d
ORDER BY id(d) ASC
LIMIT 1

//return patty,alice,tom,wine,kabi;
