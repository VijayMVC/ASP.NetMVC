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
    
    public partial class tblClassTeacher
    {
        public int ClassTeacherId { get; set; }
        public int ClassId { get; set; }
        public int UserId { get; set; }
        public System.DateTime CreateDatetime { get; set; }
        public Nullable<System.DateTime> ChangeDatetime { get; set; }
    
        public virtual tblClass tblClass { get; set; }
        public virtual tblUser tblUser { get; set; }
    }
}
