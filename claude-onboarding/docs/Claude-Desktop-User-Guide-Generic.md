# Getting Started with Claude
**[Your Organization] | Information Technology**

Welcome. If someone from IT set this up on your computer, it means we think this tool can genuinely make your workday easier - not just in theory, but in the kind of daily tasks that eat up more time than they should.

This guide is written for everyone, regardless of your tech comfort level. You do not need to know anything about artificial intelligence or software. If you can send an email and save a file, you have everything you need to use Claude.

---

## First, a mindset shift

Claude is not a search engine. The biggest mistake new users make is treating it like Google - typing a few words and hoping for the best. That approach will give you mediocre results.

Claude works like a conversation with a knowledgeable colleague. The more context you give it, the better it does. Compare these two approaches:

**Not great:**
> *how to write a meeting summary*

**Much better:**
> *I just came out of a 45-minute department meeting and need to write a summary to send to the team. We covered three things: a new software rollout happening next month, a reminder about updated parking procedures, and a heads-up about the holiday schedule. Can you help me put this together in a clear, readable format?*

Same task. Completely different results.

This feels unnatural at first. Most of us are trained to be brief with search tools. Give yourself a week to get used to writing in full sentences, and you will start to see why it works.

---

## What you have installed

**Claude Desktop** is the application that was installed on your computer. It is where you will spend most of your time - it is a simple conversation window where you type what you need and Claude responds.

**Claude Code** is a more technical tool that runs in a terminal window. You probably do not need to use it right away. This guide focuses on Claude Desktop.

**Claude Cowork** is a mode inside Claude Desktop where Claude can work directly with files on your computer. Think of it as handing Claude a stack of documents and saying "here is the background - now help me with this project." We will get to Cowork at the end of this guide once you have the basics down.

---

## Day 1: Your first 20 minutes

### Open Claude Desktop

**Mac:** Look in your Applications folder, or press Command + Space and type Claude.

**Windows:** Look on your desktop or in the Start menu.

The first time you open it, Claude will ask you to sign in. You will need a free Anthropic account - go to claude.ai to create one if you do not have one already. After that, it opens directly every time.

### Start your first conversation

Click the text box at the bottom of the screen and type something. Here are three starter ideas:

**Try something you could use today:**
> "I need to write a short email to a vendor asking for a price quote on office supplies. Professional tone, keep it brief."

**Try something you already know the answer to (this is a good way to test it):**
> "Explain what two-factor authentication is in plain language for someone who is not very technical."

**Try something you have been putting off:**
> "I need to write a step-by-step guide for new employees on how to submit a help desk ticket. Walk me through it."

Hit Enter and see what comes back. Read it over. The first response is rarely the final answer - that is by design.

### Push back if it is not right

This is the part most new users skip, and it is the most important part.

If the response is too long, say so:
> "Can you shorten this to three bullet points?"

If the tone is off, say so:
> "This sounds too formal. Can you make it more conversational?"

If something is missing, say so:
> "This is good but it did not mention what to do if the request gets rejected. Can you add that?"

Claude does not take this personally. Pushing back and refining is exactly how the tool is supposed to work.

---

## What Claude does well

**Writing and editing**

This is where most people start and where Claude delivers the most obvious value.

- Drafting emails, announcements, and memos from scratch
- Taking rough bullet points and turning them into a polished document
- Rewriting something you have already written in a different tone
- Proofreading for grammar and clarity
- Making something shorter, clearer, or more professional

**Summarizing**

- Pulling the key points out of a long document
- Condensing a long email chain into one paragraph
- Turning meeting notes into a clean summary

**Explaining things in plain language**

If you have ever had to explain a technical process to someone non-technical, or had someone explain something to you with too much jargon, Claude is good at bridging that gap.

> "Explain how our VPN works to someone who has never heard that term."

**Creating structured content**

- Step-by-step how-to guides
- Checklists and templates
- FAQ documents
- Training materials

**Brainstorming**

If you are stuck on something, Claude is useful for generating ideas, thinking through options, or just helping you get unstuck.

> "I need to come up with three different ways to announce a new staff policy so it does not feel like another top-down memo. What are some ideas?"

---

## What Claude does not do well

Be honest with yourself about these. They matter.

**Claude can be wrong, and it will not always tell you so.**

It sounds confident. That does not mean it is correct. Always read what it produces before you use it - especially anything factual. Dates, policy details, technical specifications, legal information - verify anything important from a primary source.

**Claude does not know your organization.**

It has no access to your internal files, your HR system, your ticketing system, or any internal database. It only knows what you tell it in the conversation.

**Claude does not remember previous conversations.**

Every new session starts completely fresh. It does not know what you worked on last week. If context matters, give it context at the start of the session.

**Claude is not a decision-maker.**

It is a thinking and writing tool. Anything that requires a judgment call - personnel decisions, policy exceptions, disciplinary matters - still requires a human. Do not outsource judgment.

---

## Getting better results: a few habits worth building

**Tell Claude who the audience is.**
> "Write this for someone who has never used the system before."
> "This is going out to the whole department, including people who are not technical."

**Tell Claude what format you want.**
> "Give me a bulleted list."
> "Write this as a short paragraph, no more than four sentences."
> "Format this as a table."

**Tell Claude what you do not want.**
> "Keep it under 150 words."
> "Do not use acronyms."
> "Skip the background - they already know the context."

**Start with a clear goal, not a process.**

Instead of telling Claude how to do it, tell it what you need.

Not ideal:
> "First make a list, then turn it into paragraphs, then add a summary."

Better:
> "I need a one-page summary of our onboarding process for new staff. It should be easy to read and cover the most important steps."

---

## Your first week: things to try

**Monday:** Use Claude to draft or clean up one email you would normally agonize over.

**Tuesday:** Paste a document or article you need to read and ask Claude to summarize it in five bullet points.

**Wednesday:** Ask Claude to explain something you have always found hard to explain to others.

**Thursday:** Have Claude help you write a quick how-to guide for something you know well.

**Friday:** Look back at the week. What took longer than it should have? Could Claude have helped?

This is not a drill - it is just a way to build the habit of reaching for the tool. The people who get the most out of Claude are the ones who use it regularly for small things, not just for big projects.

---

## Getting started with Cowork

Once you are comfortable with Claude Desktop, Cowork is the next step. It is useful when you are working on an ongoing project with files, documents, and context that would take too long to paste in every session.

To start a Cowork session:

1. Open Claude Desktop
2. Click the **Cowork** tab
3. Use the folder picker to select the folder you want to work in
4. Paste the session-start prompt below and press Enter
5. Read Claude's response - it should confirm what context it loaded
6. Describe what you need

**Paste this at the start of every Cowork session:**

```
Before we start, please do the following:

1. Read the CLAUDE.md file in this folder (if one exists) and tell me
   what context you loaded from it.
2. Tell me what your active instructions are, including anything from
   your global setup.
3. Confirm you are ready to begin, and summarize in one sentence what
   kind of work this session is set up for.

Do not start any tasks yet. Wait for me to describe what I need.
```

This takes about 15 seconds. It makes sure Claude loaded the right context before it touches anything.

If your folder does not have a CLAUDE.md file, Claude will still work - it just has less context about what you are doing. Your IT administrator can help you set one up if you are working on an ongoing project.

---

## What you should never share with Claude

This is not a long list, but it is non-negotiable.

**Student records.** Names, IDs, grades, enrollment status, contact information - anything tied to a student. This includes anything you pulled from a student information system.

**Employee HR data.** Salary information, performance reviews, disciplinary records, medical information.

**Passwords and credentials.** If you think you need to share a password with Claude to complete a task, stop and call IT instead.

**Anything you would not put in an email to the general public.** That is not a perfect test, but it is a good gut check.

If you are not sure, ask IT before you paste it in. There is no such thing as a dumb question when it comes to data privacy.

---

## Common problems and what to do

| Problem | What to do |
|---------|------------|
| Claude gave me wrong information | Do not use it. Correct Claude in the chat, or verify from another source. |
| The response is way too long | Ask Claude to shorten it. Be specific - "two paragraphs" or "five bullets." |
| Claude keeps misunderstanding what I need | Start a new conversation with a clearer description of the goal. |
| Claude stopped responding | Refresh the page or restart the app. Your conversation history is usually still there. |
| I accidentally shared something sensitive | Contact IT right away. |
| I have no idea where to start | Come to IT. That is what we are here for. |

---

## A word of reassurance

Using a new tool always has a learning curve, and AI tools in particular can feel strange at first. That is completely normal. Some of the most useful sessions people have with Claude happen after the third or fourth exchange, not the first.

If you try it and feel like you are doing it wrong, you are probably not. Give it a few days of regular use before you decide whether it works for you.

We would rather you ask questions than struggle in silence. Reach out anytime.

---

**[Your IT Help Desk Name]**
Phone: [IT Help Desk Phone]
Email: [IT Help Desk Email]

*This guide is maintained by [Your Name], [Your Organization] IT Department.*
*For questions or suggestions, contact [your-email@example.com].*
