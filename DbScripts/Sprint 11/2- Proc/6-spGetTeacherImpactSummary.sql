IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'spGetTeacherImpactSummary')
BEGIN
	DROP PROCEDURE spGetTeacherImpactSummary
END	
GO
CREATE PROCEDURE [dbo].[spGetTeacherImpactSummary]          
      @teacherId INT,          
      @schoolId INT,          
      @schoolYearId INT,    
      @ClassId INT,    
      @ViewMeetExceedSummary BIT ,
      @tblTempStudents StudentType READONLY
AS          
      BEGIN          
            DECLARE @districtId INT 
			DECLARE @AssessmentTypeId INT             
  
            DECLARE @tblTempBase  TABLE    
            (   
                   Grade  INT  
                  ,AssessmentType VARCHAR(200)    
                  ,ClassSubject VARCHAR(200)  
                  ,AssessmentTypeId  INT  
                  ,Weighting  FLOAT  
                  ,Impact FLOAT   
                  ,SubjectId INT    
                  ,NoOfStudent  INT      
                  ,Average FLOAT   
                  ,AssessmentGradeWeightingId  INT  
                  ,SchoolTermId INT    
                  ,SortCriteria1 INT  
                  ,SortCriteria2 INT  
                  ,IsAssessmentExist BIT 
				  ,ReportTemplateId INT 
            )      
                          
            SET @districtId = (SELECT districtId FROM tblSchool WHERE SchoolId = @SchoolId)  
			SET @AssessmentTypeId=(SELECT AssessmentTypeId FROM TBLAssessmentType WHERE AssessmentTypeDesc = 'F & P') 
           
			INSERT INTO @tblTempBase
				   
                        SELECT   
                        DISTINCT  
                        ass.GradeLevel Grade,  
                        at.AssessmentTypeDesc AssessmentTypeDesc, 
                        sub.SubjectDesc SubjectDesc,  
                        a.AssessmentTypeId AssessmentTypeId,  
                        agw.Weighting Weighting,  
                        maxterm.Impact Impact,  
                        a.SubjectId SubjectId,  
                        maxterm.NumOfStudent  NumOfStudent,  
                        maxterm.Average Average,  
                        agw.AssessmentGradeWeightingId AssessmentGradeWeightingId,  
                        maxterm.SchoolTermId SchoolTermId,  
                        CASE(@ViewMeetExceedSummary) WHEN 0 THEN ass.GradeLevel ELSE a.SubjectId END AS SortCriteria1,  
                        CASE(@ViewMeetExceedSummary) WHEN 0 THEN a.SubjectId ELSE ass.GradeLevel END AS SortCriteria2,  
                        1 AS IsAssessmentExist,
						at.ReportTemplateId ReportTemplateId
                        FROM tblAssessment A   
                        JOIN tblAssessmentType at ON at.AssessmentTypeId = a.AssessmentTypeId  
                        JOIN tblSubject sub ON a.SubjectId = sub.SubjectId  
                        JOIN tblAssessmentScore ASS ON a.AssessmentId=ass.AssessmentId   
                        JOIN tblSchool sch ON sch.SchoolId=ass.SchoolId  
                        JOIN tblAssessmentWeighting aw ON aw.DistrictId = sch.DistrictId AND aw.SchoolYearId = a.SchoolYearId AND aw.AssessmentTypeId = a.AssessmentTypeId AND aw.SubjectId = a.SubjectId  
						JOIN tblAssessmentGradeWeighting agw ON agw.AssessmentWeightingId = aw.AssessmentWeightingId AND ass.GradeLevel = agw.Grade  
                        JOIN ( (SELECT   
                               termtable.AssessmentTypeId,  
                               termtable.Gradelevel,
                               termtable.SubjectId,  
                               termtable.SchoolTermId,  
                               termtable.NumofStudent,  
                               termtable.Impact,  
                               termtable.Average  
								 FROM   
								 (  
									SELECT   
										 tblA.AssessmentTypeId,  
										 tblASS.Gradelevel, 
										 tblA.SubjectId,  
										 MAX(tbla.SchoolTermId) SchoolTermId,  
										 COUNT(tblASS.studentid) NumofStudent,  
										 SUM(ISNULL(tblASS.ScoreProjDif,0)) Impact,  
										(CASE COUNT(tblASS.studentid) WHEN 0 THEN 0.0 ELSE SUM(ISNULL(tblASS.ScaledScoreProjDif,0))/COUNT(tblASS.studentid)  END) AS Average  
									FROM   
										tblAssessment tblA 
										JOIN tblAssessmentScore tblASS ON tbla.AssessmentId=tblass.AssessmentId   
										JOIN tblSchool tblsch ON tblsch.SchoolId=tblass.SchoolId
									WHERE   
									--ScoreProjDif IS NOT NULL AND   
									case tblA.AssessmentTypeId when @AssessmentTypeId then ScaledScoreProjDif  else ScoreProjDif end is not null AND
									tblsch.districtId=@districtId AND   
									tblA.SchoolYearId=@schoolYearId AND  
									tblASS.studentid IN
										(	SELECT tcs.studentid 
											FROM TBLCLASSSTUDENT tcs   
											   JOIN @tblTempStudents temptcs ON tcs.studentid=temptcs.studentid  
											   JOIN tblClass tblc ON tblc.ClassId = tcs.ClassId AND tblc.SchoolYearId =  @schoolYearId    
											   JOIN tblClassTeacher tbltc1 ON tblc.ClassId = tbltc1.ClassId   
										   WHERE tbltc1.UserId=@teacherId  AND   
											tblc.ClassId = CASE WHEN @ClassId = -1 THEN tblc.ClassId  ELSE @ClassId END AND  
											tblc.SchoolYearId = CASE WHEN @ClassId = -1 THEN @SchoolYearId  ELSE tblc.SchoolYearId END   
										)    
                                    GROUP BY   
                                    tblA.AssessmentTypeId,  
                                    tblASS.Gradelevel, 
                                    tblA.SubjectId,  
                                    tbla.SchoolTermId   
                                ) termtable  
						 JOIN  
							(SELECT   
								tempA.AssessmentTypeId,  
								tempASS.Gradelevel, 
								tempA.SubjectId,  
								MAX(tempa.SchoolTermId) SchoolTermId   
                            FROM   
								tblAssessment tempA  
								JOIN tblAssessmentScore tempASS ON tempa.AssessmentId=tempass.AssessmentId   
								JOIN tblSchool tempsch ON tempsch.SchoolId=tempass.SchoolId    
                            WHERE   
								--ScoreProjDif IS NOT NULL AND  
								case tempA.AssessmentTypeId when @AssessmentTypeId then ScaledScoreProjDif  else ScoreProjDif end is not null AND 
								tempsch.districtId=@districtId AND   
								tempA.SchoolYearId=@schoolYearId AND  
								tempASS.studentid IN
										(SELECT tcs.studentid 
											FROM TBLCLASSSTUDENT tcs   
											   JOIN @tblTempStudents temptcs ON tcs.studentid=temptcs.studentid  
											   JOIN tblClass tblc ON tblc.ClassId = tcs.ClassId AND tblc.SchoolYearId =  @schoolYearId    
											   JOIN tblClassTeacher tbltc1 ON tblc.ClassId = tbltc1.ClassId   
										   where tbltc1.UserId=@teacherId  AND   
											tblc.ClassId = CASE WHEN @ClassId = -1 THEN tblc.ClassId  ELSE @ClassId END AND  
											tblc.SchoolYearId = CASE WHEN @ClassId = -1 THEN @SchoolYearId  ELSE tblc.SchoolYearId END   
										)      
                            GROUP BY   
								tempA.AssessmentTypeId,  
								tempASS.Gradelevel,  
                                tempA.SubjectId   
                            ) maxtermtable   
                                    ON   
										termtable.AssessmentTypeId=maxtermtable.AssessmentTypeId and   
										termtable.Gradelevel=maxtermtable.Gradelevel and
										termtable.SubjectId=maxtermtable.SubjectId and   
										termtable.SchoolTermId=maxtermtable.SchoolTermId   
                        WHERE  
							termtable.SchoolTermId=maxtermtable.SchoolTermId  
                        )  
                        UNION  
                        (SELECT   
							 UntempA.AssessmentTypeId,  
							 UntempASS.Gradelevel,
							 UntempA.SubjectId,  
							 max(Untempa.SchoolTermId) SchoolTermId,  
							 0 AS NumofStudent,  
							 0.0 AS Impact,  
							 0.0 AS Average   
                        FROM   
							tblAssessment UntempA  
							JOIN tblAssessmentScore UntempASS ON Untempa.AssessmentId=Untempass.AssessmentId   
							JOIN tblSchool Untempsch ON Untempsch.SchoolId=Untempass.SchoolId   
                        WHERE   
							Untempsch.districtId=@districtId AND   
							UntempA.SchoolYearId=@schoolYearId  AND  
							UntempASS.studentid IN
										(SELECT tcs.studentid 
											FROM TBLCLASSSTUDENT tcs   
											   JOIN @tblTempStudents temptcs ON tcs.studentid=temptcs.studentid  
											   JOIN tblClass tblc ON tblc.ClassId = tcs.ClassId AND tblc.SchoolYearId =  @schoolYearId    
											   JOIN tblClassTeacher tbltc1 ON tblc.ClassId = tbltc1.ClassId   
										   WHERE tbltc1.UserId=@teacherId  AND   
											tblc.ClassId = CASE WHEN @ClassId = -1 THEN tblc.ClassId  ELSE @ClassId END AND  
											tblc.SchoolYearId = CASE WHEN @ClassId = -1 THEN @SchoolYearId  ELSE tblc.SchoolYearId END   
										)    
                        GROUP BY   
							UntempA.AssessmentTypeId,  
							UntempASS.Gradelevel,  
							UntempA.SubjectId  
							--HAVING SUM(UntempASS.ScoreProjDif) IS NULL) 
							 HAVING SUM(case UntempA.AssessmentTypeId when @AssessmentTypeId then ScaledScoreProjDif  else ScoreProjDif end) IS NULL) 
							
                                       
                        ) maxterm   
                        ON   
							A.SchoolTermId=maxterm.SchoolTermId AND   
							maxterm.AssessmentTypeId=a.AssessmentTypeId AND   
							maxterm.Gradelevel=ass.GradeLevel AND  
							maxterm.SubjectId =a.SubjectId   
                        WHERE   
							sch.DistrictId=@DistrictId AND   
							a.SchoolYearId=@schoolYearId AND 
							ass.studentid IN(SELECT st.studentid FROM TBLCLASSSTUDENT st   
							JOIN @tblTempStudents tempst ON st.studentid=tempst.studentid  
							JOIN tblClass c ON c.ClassId = st.ClassId 							
							AND c.SchoolYearId =  @schoolYearId    
							JOIN tblClassTeacher tc1 ON c.ClassId = tc1.ClassId   
                        WHERE tc1.UserId=@teacherId  AND   
							c.ClassId = CASE WHEN @ClassId = -1 THEN c.ClassId  ELSE @ClassId END AND  
							c.SchoolYearId = CASE WHEN @ClassId = -1 THEN @SchoolYearId  ELSE c.SchoolYearId END   
						)               
					  
					IF EXISTS(SELECT TOP 1 * FROM @tblTempBase)
							BEGIN
											  INSERT INTO @tblTempBase(Grade,SubjectId,AssessmentTypeId,AssessmentType,ClassSubject,Weighting,AssessmentGradeWeightingId,SortCriteria1,SortCriteria2,IsAssessmentExist,ReportTemplateId)  
											  SELECT   DISTINCT 
											  tblbase.grade,tblbase.subjectid,aw.AssessmentTypeId,at.AssessmentTypeDesc,
											  tblbase.ClassSubject,agw.Weighting,agw.AssessmentGradeWeightingId,
											  tblbase.SortCriteria1,tblbase.SortCriteria2,0, at.ReportTemplateId  
											  FROM tblAssessmentWeighting aw   
											  JOIN tblAssessmentGradeWeighting agw ON agw.AssessmentWeightingId = aw.AssessmentWeightingId   
											  JOIN tblAssessmentType at ON at.AssessmentTypeId = aw.AssessmentTypeId
											  JOIN @tblTempBase tblbase ON aw.subjectid = tblbase.subjectid AND agw.grADE =tblbase.grade  AND   
											  aw.DISTRICTID = @DistrictId AND aw.schoolyearid = @schoolYearId     
											  WHERE  NOT EXISTS (SELECT t.AssessmentTypeId FROM @tblTempBase t 
																						   WHERE 
																						   t.subjectid= tblbase.subjectid and 
																						   t.grADE = tblbase.grade and  
																						   t.AssessmentTypeId= aw.AssessmentTypeId
											)
							END  
              
            SELECT    
                  Grade  
                  ,AssessmentType   
                  ,ClassSubject   
                  ,AssessmentTypeId  
                  ,Weighting   
                  ,Impact   
                  ,SubjectId   
                  ,NoOfStudent    
                  ,Average   
                  ,AssessmentGradeWeightingId   
                  ,SchoolTermId   
                  ,SortCriteria1   
                  ,SortCriteria2   
                  ,IsAssessmentExist  
				  ,ReportTemplateId 
            FROM @tblTempBase   
            ORDER BY SortCriteria1,SortCriteria2, Weighting DESC,AssessmentType  
              
      END