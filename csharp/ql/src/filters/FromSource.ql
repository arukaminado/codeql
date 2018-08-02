/**
 * @name Filter: only keep results from source
 * @description Exclude results that do not come from source code files.
 * @kind problem
 * @deprecated
 */
import csharp
import external.DefectFilter

from DefectResult res
where res.getFile().fromSource()
select res,
       res.getMessage()
