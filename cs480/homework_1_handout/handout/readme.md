# Homework 1

## Solve the homework

- **Do not rename any of the files or move them to a subdirectory in the archive as the autograder only looks for files in the main directory of the archive and expects files to have the same names as in the provided submission template!**
- **Do not include the pdf file into the uploaded archive!**

The autograder uses PostgreSQL ([https://www.postgresql.org/](https://www.postgresql.org/)) for SQL and relational algebra questions. For relational algebra we execute your code using **radb**:  [https://users.cs.duke.edu/~junyang/radb/start.html](https://users.cs.duke.edu/~junyang/radb/start.html)

The file `homework_1.sql` contains SQL code for generating the schema and loading the test data.

## Prepare and upload solutions

To upload your solution to Gradescope, create a single archive named `submission.zip` containing all of your files at the top level directory. You can use the makefile in this directory to do that:

```sh
make
```

**The files have to be in the main folder of the archive for the autograder to be able to find them.**

To check this run:

```sh
unzip -l submission.zip

Archive:  submission.zip
  Length      Date    Time    Name
---------  ---------- -----   ----
       50  03-01-2024 15:07   Makefile
        0  03-01-2024 15:08   q1.1.1.ra
        0  03-01-2024 15:08   q1.1.2.ra
        0  03-01-2024 15:08   q1.2.1.ra
        0  03-01-2024 15:09   q1.2.2.ra
        0  03-01-2024 15:09   q1.2.3.ra
        0  03-01-2024 15:09   q1.2.4.ra
        0  03-01-2024 15:09   q1.2.5.ra
        0  03-01-2024 15:09   q1.2.6.ra
        0  03-01-2024 15:09   q1.2.7.ra
        0  03-01-2024 15:09   q1.2.8.ra
        0  03-01-2024 15:09   q1.3.1.ra
        0  03-01-2024 15:09   q1.3.2.ra
        0  03-01-2024 15:09   q1.3.3.ra
        0  03-01-2024 15:09   q1.3.4.ra
        0  02-26-2025 11:18   q1.4.1.ra
     1044  01-04-2026 14:21   readme.md
---------                     -------
     1094                     17 files
```


Once you have a `submission.zip` file, you can upload it through Gradescope's webinterface. After the autograder is done it will provide you with feedback about your solutions. That is, it will tell you how your results differ from the expected results. You can submit as often as you want.

## Relational algebra questions

 Solutions for these questions have to be written in the provided text files (e.g., `q1.1.1.ra` for question `1.1.1`. Relational algebra expressions are written in the format of the `radb` python package ([https://users.cs.duke.edu/~junyang/radb/start.html](https://users.cs.duke.edu/~junyang/radb/start.html)). To test your code, install this package and use it to connect to a database (the autograder uses Postgres: [https://www.postgresql.org/](https://www.postgresql.org)) that has the provide example schema and data (load `homework_1.sql`). For example, a projection on the `title` attribute of the `songs` table would we written as follows in `radb`'s dialect:

```
\project_{title}(songs)
```

**Note that table and attribute names are lowercase in Postgres.**
