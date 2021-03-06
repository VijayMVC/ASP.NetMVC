USE [dbTIR]
GO
/****** Object:  UserDefinedFunction [dbo].[udfGetMeetExceedCriteriaValue]    Script Date: 10/7/2014 10:12:11 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sachin Gupta
-- Create date: 10/01/14
-- Description:	udfGetMeetExceedCriteriaValue returns meet exceed criteria value on bais of ImpactScore.
-- =============================================


CREATE FUNCTION [dbo].[udfGetMeetExceedCriteriaValue]
(
   @DistrictId INT,
   @SubjectId INT,            
   @SchoolYearId INT,            
   @AssessmentTypeId INT,  
   @ImpactScore DECIMAL (6,3)      
)
RETURNS INT
AS
BEGIN
	
	DECLARE @MeetExceedValue INT
	SET @MeetExceedValue = NULL
	
	IF @ImpactScore IS NOT NULL
	BEGIN
		SELECT  
			@MeetExceedValue =	CASE  
			                          WHEN (@ImpactScore < StartRange) THEN -1 
								      WHEN (@ImpactScore >= EndRange) THEN 1 
								      ELSE 0 
							     END
		FROM tblAssessmentWeighting aw
		INNER JOIN tblAssessmentMeetExceedCriteria ac ON aw.AssessmentWeightingId = ac.AssessmentWeightingId
		WHERE DistrictId = @DistrictId AND AssessmentTypeId = @AssessmentTypeId 
			  AND SchoolYearId = @SchoolYearId AND SubjectId = @SubjectId
	END
	
	RETURN @MeetExceedValue
END
