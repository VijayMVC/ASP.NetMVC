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
    
    public partial class tblSchool
    {
        public tblSchool()
        {
            this.tblClasses = new HashSet<tblClass>();
            this.tblStudentSchoolYears = new HashSet<tblStudentSchoolYear>();
            this.tblUserSchools = new HashSet<tblUserSchool>();
        }
    
        public int SchoolId { get; set; }
        public int DistrictId { get; set; }
        public string SchoolDesc { get; set; }
        public Nullable<int> AddressId { get; set; }
        public string SchoolAbbr { get; set; }
        public System.DateTime CreateDatetime { get; set; }
        public Nullable<System.DateTime> ChangeDatetime { get; set; }
        public string RcdtsCode { get; set; }
        public string SchoolDescOriginal { get; set; }
    
        public virtual tblAddress tblAddress { get; set; }
        public virtual ICollection<tblClass> tblClasses { get; set; }
        public virtual tblDistrict tblDistrict { get; set; }
        public virtual ICollection<tblStudentSchoolYear> tblStudentSchoolYears { get; set; }
        public virtual ICollection<tblUserSchool> tblUserSchools { get; set; }
    }
}
