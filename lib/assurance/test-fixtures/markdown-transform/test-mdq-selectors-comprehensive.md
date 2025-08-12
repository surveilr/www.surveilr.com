---
title: "Comprehensive mdq Selector Test File"
description: "Test file for all mdq selectors in Surveilr transform-markdown"
---

# Alpha Section

This is a paragraph in the Alpha section with some regular text content.

## Sub-section Header

Another paragraph here with more detailed information.

### Tertiary Header

Content under the tertiary header.

# Bravo Section  

This is the Bravo section content.

## Lists Section

### Unordered Lists
- First unordered item
- Second unordered item  
- Third unordered item

### Ordered Lists
1. First ordered item
2. Second ordered item
3. Third ordered item

### Task Lists
- [ ] Incomplete task item
- [x] Completed task item
- [ ] Another incomplete task
- [x] Another completed task

## Links and References

Here are various links to test:
- [an inline](https://example.com) link
- Reference link: [referenced link][ref1]
- Another [inline link](example.com) 
- Image: ![alt text](image.png)

[ref1]: /referenced "Referenced URL"

## Blockquotes

> This is a single blockquote with some text.

> This is blockquote two with different content.

> - This is a blockquote with a list item
> - Another list item in blockquote  

> Multi-line blockquote
> that spans several lines
> with more content.

## Paragraphs Section

This is a standalone paragraph for paragraph selection testing.

Another paragraph with different content to test paragraph selectors.

A third paragraph with more text content.

## Tables

| Column A | Column B | Column C |
|----------|----------|----------|
| Alpha    | Beta     | Gamma    |
| One      | Two      | Three    |
| Red      | Green    | Blue     |

| Name        | Description      | Status |
|-------------|------------------|--------|
| Item 1      | First item       | Active |
| Item 2      | Second item      | Inactive |

## Code Blocks

```javascript
function example() {
    console.log("JavaScript code");
}
```

```python  
def python_example():
    print("Python code")
```

## Final Section

This is the final section with concluding content for comprehensive testing.