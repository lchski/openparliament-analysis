# Getting the data

## Load database

prep:
[install postgres]
[load openparliament data dump into postgresql in a db named openparliament]

## ETHI statements

ETHI committee ID is 56.

Get all statements from ETHI in session 42-1:

```
SELECT * FROM hansards_statement
  LEFT JOIN committees_committeemeeting
    ON committees_committeemeeting.evidence_id = hansards_statement.document_id
  WHERE
    (committee_id = 56) AND
    (session_id = '42-1');
```

Get all ETHI meetings in session 42-1:

```
SELECT * from committees_committeemeeting
  WHERE
    (committee_id = 56) AND
    (session_id = '42-1');
```


Tables of interest:

* `committees_committeemeeting` (`evidence_id` connects to `hansards_document.id`)
* `hansards_document`
* `hansards_statement` (`document_id` connects to `hansards_document.id`)

So, we can get all the statements for ETHI meetings by connecting `hansards_statement.document_id` to `committees_committeemeeting.evidence_id`.

Look also into "activities" (e.g. reports): `committees_committeeactivity`, `committees_committeemeeting_activities`


## MPs

Get MP data:

```
SELECT * FROM core_electedmember
  RIGHT JOIN core_party
    ON core_electedmember.party_id = core_party.id
  RIGHT JOIN core_politician
    ON core_electedmember.politician_id = core_politician.id;
```
