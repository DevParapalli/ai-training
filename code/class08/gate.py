# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""Class 8: the gate. Nothing goes to a tool above that tool's limit, and nothing unclassified goes anywhere."""
LEVELS = ["LOL Public", "LOL Internal", "LOL Confidential", "LOL Highly Confidential", "LOL Restricted"]

# The approved tool directory, as the policy slide shows it.
DIRECTORY = {
    "lighthouse": "LOL Restricted",
    "servicedesk-ai": "LOL Highly Confidential",
    "local-model": "LOL Confidential",
}


def allowed(tool: str, data_class: str | None) -> bool:
    if data_class not in LEVELS:                    # unclassified: refuse, don't guess
        return False
    limit = DIRECTORY.get(tool, "LOL Public")       # anything not in the directory
    return LEVELS.index(data_class) <= LEVELS.index(limit)


if __name__ == "__main__":
    for tool, cls in [("lighthouse", "LOL Restricted"), ("servicedesk-ai", "LOL Restricted"),
                      ("local-model", "LOL Confidential"), ("some-chatbot", "LOL Internal"),
                      ("lighthouse", None)]:
        print(f"{tool:<15} {str(cls):<25} {'send' if allowed(tool, cls) else 'BLOCK'}")
