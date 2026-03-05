# Contributing to DocuMorph

Thank you for considering contributing to DocuMorph. This project is developed and maintained by Jim Daley, and contributions are welcome to improve the app. Please follow these guidelines to ensure smooth collaboration.

## Code of Conduct

Be respectful, inclusive, and professional in all interactions.

## Forsetti Framework Guidelines

DocuMorph is built on the Forsetti Framework. Contributors must follow these rules:

### Sealed Framework Constraint

Forsetti is included as a vendored local package in `Packages/ForsettiFramework/`. It must be treated as a sealed dependency:

- **Allowed**: Use Forsetti through its public APIs. Implement modules using `ForsettiAppModule`, `ForsettiUIModule`, or `ForsettiModule`. Use the service container and protocol-based contracts.
- **Not allowed**: Modifying, copying, forking, or patching Forsetti internals. Adding reverse dependencies from app targets into Forsetti internals. Bypassing entitlement or capability checks.

If a required extension point is missing, request a framework enhancement rather than patching internals.

### OOP and Architecture Rules

- Use `final class` for all production classes unless extension is intentional and documented.
- Prefer protocol-first design for contracts and behavior boundaries.
- Use constructor dependency injection for collaborators.
- Avoid hidden global state and implicit service lookup patterns.
- Keep dependencies one-way; no circular dependencies.
- Use native Apple technologies only (Swift, SwiftUI, Apple frameworks).

### Required Verification

Before submitting a pull request, run:

```bash
xcodebuild -project "DocuMorph.xcodeproj" \
  -scheme "DocuMorph" \
  -configuration Debug \
  -sdk macosx \
  build
```

## How to Contribute

1. **Fork the Repository**: Create a fork of the repo on GitHub.
2. **Create a Branch**: Use a descriptive name, e.g., `feature/add-new-converter` or `bugfix/fix-pdf-parsing`.
3. **Make Changes**: Follow Swift coding conventions and Forsetti architecture rules:
   - Use 4-space indentation.
   - Keep code modular and testable.
   - Mark all new classes as `final`.
   - Add comments where necessary.
   - Update documentation if features change.
4. **Test Your Changes**: Build and run the app in Xcode. Test conversions with sample files.
5. **Commit Changes**: Use clear commit messages, e.g., "Add support for TXT files in TextConverter".
6. **Submit a Pull Request**: Target the main branch. Include a description of changes, why they're needed, and any relevant issues.

## Reporting Issues

- Use GitHub Issues to report bugs or suggest enhancements.
- Provide details: Steps to reproduce, expected vs. actual behavior, screenshots if applicable.
- Label issues appropriately (e.g., `bug`, `enhancement`, `documentation`).

## Development Setup

- macOS with Xcode 16+.
- No external dependencies; uses Apple frameworks and the vendored Forsetti Framework.

## Review Process

Pull requests will be reviewed by Jim Daley or designated maintainers. Changes must:
- Align with the project's goals and maintain code quality.
- Follow Forsetti architecture rules (sealed framework, final classes, DI).
- Pass build verification.

For questions, contact Jim Daley via repository issues.

*Last updated: March 5, 2026*
