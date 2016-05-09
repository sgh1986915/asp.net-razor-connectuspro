﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace SiteBlue.Areas.Admin.Models
{
    public class ReportViewModel
    {
        public int FranchiseID { get; set; }
        public DateTime FromDate { get; set; }
        public DateTime ToDate { get; set; }
        public List<SelectListItem> TimePeriod { get; set; }
        public string Range { get; set; }
    }
}