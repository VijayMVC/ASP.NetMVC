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
    
    public partial class tblUserPasswordResetToken
    {
        public int ResetId { get; set; }
        public string ResetToken { get; set; }
        public string ResetUser { get; set; }
        public string ResetEmail { get; set; }
        public System.DateTime CreatedDateTime { get; set; }
    }
}
