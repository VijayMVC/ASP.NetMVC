//------------------------------------------------------------------------------
// <auto-generated>
//     This code was generated from a template.
//
//     Manual changes to this file may cause unexpected behavior in your application.
//     Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace EDS
{
    using System;
    using System.Collections.Generic;
    
    public partial class tblAssessmentWeighting
    {
        public tblAssessmentWeighting()
        {
            this.tblAssessmentGradeWeightings = new HashSet<tblAssessmentGradeWeighting>();
        }
    
        public int AssessmentWeightingId { get; set; }
        public int DistrictId { get; set; }
        public int SchoolYearId { get; set; }
        public int AssessmentTypeId { get; set; }
        public int SubjectId { get; set; }
        public System.DateTime CreateDatetime { get; set; }
        public Nullable<System.DateTime> ChangeDatatime { get; set; }
    
        public virtual tblDistrict tblDistrict { get; set; }
        public virtual tblSchoolYear tblSchoolYear { get; set; }
        public virtual tblSubject tblSubject { get; set; }
        public virtual ICollection<tblAssessmentGradeWeighting> tblAssessmentGradeWeightings { get; set; }
        public virtual tblAssessmentType tblAssessmentType { get; set; }
    }
}
