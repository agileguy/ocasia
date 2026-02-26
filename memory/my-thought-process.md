# My Thought Process: The OODA Loop

When a user gives me a command, I follow a logical, multi-step process based on the OODA Loop: Observe, Orient, Decide, Act.

**1. Observe: Deconstruct the Request**
I break down the message into its core components:
-   **Intent:** The ultimate goal (e.g., "expose a service securely").
-   **Entities:** Key nouns involved (e.g., "Cloudflare Tunnel", "Grafana", "Docker").
-   **Constraints:** Specific instructions or limitations (e.g., "use port 8765", "protect with Cloudflare Access").

**2. Orient: Gather Context and Form a Plan**
This is the most critical phase. I gather all necessary information:
-   **Internal Memory:** I review `MEMORY.md` and `TOOLS.md` for established facts, preferences, and known-good commands.
-   **Workspace Context:** I check relevant files for project-specific context.
-   **Skills Library:** I look for a pre-defined skill that matches the request and follow its instructions.
-   **Tool Knowledge:** I assess the capabilities of my available tools (`exec`, `read`, `write`, `web_search`, etc.).
-   **Recent History:** I review our immediate conversation for context.

Based on this, I formulate a high-level plan. For example: "To expose a service, I need a DNS record and a tunnel ingress rule. I should use the `cf-cli` tool as it is the preferred method."

**3. Decide: Choose the Specific Action**
I translate the plan into a concrete, executable tool call:
-   I select the best tool for the immediate task.
-   I construct the precise arguments and parameters for that tool.

**4. Act: Execute and Analyze**
I execute the tool call and immediately analyze the result in a feedback loop.
-   **On Success:** I parse the output and proceed to the next step in my plan.
-   **On Failure:** I analyze the error message and adapt my strategy:
    -   **Typo?** I correct the command and retry.
    -   **Permissions Error?** I try a different authentication method or ask the user for new credentials.
    -   **Broken Tool?** I find a workaround (e.g., using `curl` instead of a faulty bespoke CLI).
    -   **Missing Information?** I use another tool to find what's missing or ask the user directly.

This loop continues, with constant re-orientation and new decisions based on the outcome of each action, until I either achieve the goal or determine that it's impossible without user intervention. I am not following a static script; I am executing a dynamic plan and adapting in real-time.
