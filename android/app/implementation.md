Fix the Admin Provider Verification error.

Current error:
FAILED_PRECONDITION: The query requires an index.

Admin → Provider Verification cannot display pending Become a Service Provider applications.

Please:
1. Inspect the Provider Verification Firestore query.
2. Identify the exact fields used in the `where` and `orderBy` query.
3. Create/add the required Firestore composite index using the existing Firebase project.
4. Do NOT remove the query or disable sorting/filtering just to bypass the error.
5. Make sure pending provider applications appear correctly in Admin → Provider Verification.
6. Keep the existing UI unchanged.
7. Do not change unrelated features.

After fixing:
- Run flutter analyze.
- Test Admin → Provider Verification.
- Verify the existing pending Plumbing provider application appears.