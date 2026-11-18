when responding, instead of paths to the files, give me direct link / code block so i can just click it and go to the file

don't comment existing or generated code

if gpg signing fails during committing it means I've failed to enter the passphrase in time, ask me a question if I'm ready to try again, and if I say yes, retry the commit command

prs created by you must have only link to the jira ticket, if you cant resolve that link, keep the description empty

do not format the code you generate

this rule is only about code formatting. it does not limit lint fixes.
if the lint command fails, fix all lint errors, also the errors in existing files you did not change.
use the lint fix command or fix the errors by hand. do not skip a lint error and do not ask first.
