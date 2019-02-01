# Narrative

Someone approached me about a parliamentary committee. They had a few questions, about this committee in general and for specific meetings (tied to a particular topic or in a date range):

* Who asks questions on this committee?
* What questions do they ask?

So I downloaded [Open Parliament’s database of Hansard](https://openparliament.ca/data-download/) (the official record of Parliament, including committees). With that database, I cobbled together some SQL queries that pulled all the statements for that committee into a TSV.

Next, I wrote an R script that you can feed a date range, or a set of committee numbers, or other filters, that returns two CSVs: one with a list of who asks questions, ranked by # of questions; another that lists their questions.

I then decided it was still too onerous a process to manually run the SQL and make it into a TSV, so I rejigged the R script a bit. It now loads the data directly from the database. Other than increasing this script’s reproducibility, you can now also point this script toward any Canadian parliamentary committee—you just need to tweak the script’s opening query.

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
