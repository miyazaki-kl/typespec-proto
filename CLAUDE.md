# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a TypeSpec prototype project for generating OpenAPI 3.1.0 schemas from TypeSpec definitions. The project is configured to output OpenAPI YAML files to the `tsp-output/schema/` directory.

## Common Commands

```bash
# Install dependencies
npm install

# Compile TypeSpec to OpenAPI schema
npx tsp compile .

# Compile with specific emitter (alternative)
npx tsp compile . --emit=@typespec/openapi3
```

## Architecture and Structure

- **main.tsp**: Primary TypeSpec definition file containing a sample "Widget Service" API with CRUD operations
- **tspconfig.yaml**: TypeSpec compiler configuration that outputs OpenAPI 3.1.0 schemas to `tsp-output/schema/`
- **package.json**: Uses TypeSpec compiler and HTTP/REST/OpenAPI libraries (all set to "latest")
- **tsp-output/schema/**: Output directory for generated OpenAPI YAML files

The TypeSpec definition includes:
- Widget model with id, weight, and color properties
- REST API interface with standard CRUD operations
- Error handling model
- Additional analyze endpoint for widgets

## TypeSpec Configuration

The project uses `@typespec/openapi3` emitter with:
- Output directory: `tsp-output/schema/`
- OpenAPI version: 3.1.0
- Standard HTTP decorators for REST API definitions

## Development Notes

- The README.md mentions plans for Java code generation using `@typespec/http-client-java`, but the current configuration only generates OpenAPI schemas
- Package manager is locked to npm@11.5.2
- All TypeSpec dependencies are set to "latest" versions