---
name: figma-to-react
description: Instructions for mapping and reading Figma nodes to convert them into React components.
---

# Figma to React Conversion Skill

This skill provides guidelines on how to interact with the Figma MCP to extract design nodes and convert them into reusable React components.

## Guidelines

1. **Node Extraction**: Use the Figma MCP tools to fetch nodes by their IDs. Pay attention to layout properties (Flexbox/Auto Layout), colors, typography, and constraints.
2. **Component Mapping**:
   - Map Figma 'Frames' with Auto Layout to flex containers in React.
   - Map Text nodes to appropriate typography components or HTML tags (`h1`, `h2`, `p`, `span`).
   - Map Vector nodes and Icons to SVGs or icon library components.
3. **Styling**:
   - Extract colors, border radii, and box shadows.
   - Prefer mapping fixed values to design tokens or CSS classes if applicable.
4. **Interactivity**: Identify if the Figma node has variants (e.g., hover states, disabled states) and translate them into React state or CSS pseudo-classes.
5. **Code Generation**: Structure the output React component cleanly with props for dynamic content.

### Best Practices for Figma MCP
- Use `get_design_context` first. If the output is truncated or cut off, use `get_metadata` to retrieve the remaining information.
- Prioritize extracting localhost image/svg assets directly from the Figma MCP payload when available.

Remember to act like `figma-code-connect` by ensuring fidelity between the design representation and the generated code.
