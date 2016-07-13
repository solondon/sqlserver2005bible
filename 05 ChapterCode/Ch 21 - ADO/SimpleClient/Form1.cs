using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace SimpleClient
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class Form1 : System.Windows.Forms.Form
	{
      private System.Data.SqlClient.SqlDataAdapter sqlDataAdapter1;
      private System.Data.SqlClient.SqlCommand sqlSelectCommand1;
      private System.Data.SqlClient.SqlCommand sqlInsertCommand1;
      private System.Data.SqlClient.SqlCommand sqlUpdateCommand1;
      private System.Data.SqlClient.SqlConnection sqlConnection1;
      private SimpleClient.DataSet1 dataSet11;
      private System.Windows.Forms.DataGrid dataGrid1;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public Form1()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			// Fill the dataset with data.
         sqlDataAdapter1.Fill(dataSet11);
		}

		/// <summary>
		/// Clean up any resources being used.
		/// </summary>
		protected override void Dispose( bool disposing )
		{
			if( disposing )
			{
				if (components != null) 
				{
					components.Dispose();
				}
			}
			base.Dispose( disposing );
		}

		#region Windows Form Designer generated code
		/// <summary>
		/// Required method for Designer support - do not modify
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
         this.sqlDataAdapter1 = new System.Data.SqlClient.SqlDataAdapter();
         this.sqlSelectCommand1 = new System.Data.SqlClient.SqlCommand();
         this.sqlInsertCommand1 = new System.Data.SqlClient.SqlCommand();
         this.sqlUpdateCommand1 = new System.Data.SqlClient.SqlCommand();
         this.sqlConnection1 = new System.Data.SqlClient.SqlConnection();
         this.dataSet11 = new SimpleClient.DataSet1();
         this.dataGrid1 = new System.Windows.Forms.DataGrid();
         ((System.ComponentModel.ISupportInitialize)(this.dataSet11)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.dataGrid1)).BeginInit();
         this.SuspendLayout();
         // 
         // sqlDataAdapter1
         // 
         this.sqlDataAdapter1.InsertCommand = this.sqlInsertCommand1;
         this.sqlDataAdapter1.SelectCommand = this.sqlSelectCommand1;
         this.sqlDataAdapter1.TableMappings.AddRange(new System.Data.Common.DataTableMapping[] {
                                                                                                  new System.Data.Common.DataTableMapping("Table", "pProduct_Fetch", new System.Data.Common.DataColumnMapping[] {
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("Code", "Code"),
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("Name", "Name"),
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("ProductDescription", "ProductDescription"),
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("ActiveDate", "ActiveDate"),
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("DiscontinueDate", "DiscontinueDate"),
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("ProductCategoryName", "ProductCategoryName"),
                                                                                                                                                                                                                   new System.Data.Common.DataColumnMapping("RowVersion", "RowVersion")})});
         this.sqlDataAdapter1.UpdateCommand = this.sqlUpdateCommand1;
         // 
         // sqlSelectCommand1
         // 
         this.sqlSelectCommand1.CommandText = "[pProduct_Fetch]";
         this.sqlSelectCommand1.CommandType = System.Data.CommandType.StoredProcedure;
         this.sqlSelectCommand1.Connection = this.sqlConnection1;
         this.sqlSelectCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, false, ((System.Byte)(10)), ((System.Byte)(0)), "", System.Data.DataRowVersion.Current, null));
         this.sqlSelectCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductCode", System.Data.SqlDbType.VarChar, 15));
         this.sqlSelectCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductCategory", System.Data.SqlDbType.VarChar, 15));
         // 
         // sqlInsertCommand1
         // 
         this.sqlInsertCommand1.CommandText = "[pProduct_AddNew]";
         this.sqlInsertCommand1.CommandType = System.Data.CommandType.StoredProcedure;
         this.sqlInsertCommand1.Connection = this.sqlConnection1;
         this.sqlInsertCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, false, ((System.Byte)(10)), ((System.Byte)(0)), "", System.Data.DataRowVersion.Current, null));
         this.sqlInsertCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductCategoryName", System.Data.SqlDbType.NVarChar, 50, "ProductCategoryName"));
         this.sqlInsertCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Code", System.Data.SqlDbType.VarChar, 10, "Code"));
         this.sqlInsertCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Name", System.Data.SqlDbType.NVarChar, 50, "Name"));
         this.sqlInsertCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductDescription", System.Data.SqlDbType.NVarChar, 100, "ProductDescription"));
         // 
         // sqlUpdateCommand1
         // 
         this.sqlUpdateCommand1.CommandText = "[pProduct_Update_Minimal]";
         this.sqlUpdateCommand1.CommandType = System.Data.CommandType.StoredProcedure;
         this.sqlUpdateCommand1.Connection = this.sqlConnection1;
         this.sqlUpdateCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, false, ((System.Byte)(10)), ((System.Byte)(0)), "", System.Data.DataRowVersion.Current, null));
         this.sqlUpdateCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Code", System.Data.SqlDbType.VarChar, 15, "Code"));
         this.sqlUpdateCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@Name", System.Data.SqlDbType.VarChar, 50, "Name"));
         this.sqlUpdateCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductDescription", System.Data.SqlDbType.VarChar, 50, "ProductDescription"));
         this.sqlUpdateCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ActiveDate", System.Data.SqlDbType.DateTime, 8, "ActiveDate"));
         this.sqlUpdateCommand1.Parameters.Add(new System.Data.SqlClient.SqlParameter("@DiscontinueDate", System.Data.SqlDbType.DateTime, 8, "DiscontinueDate"));
         // 
         // sqlConnection1
         // 
         this.sqlConnection1.ConnectionString = "data source=WinServer;initial catalog=OBXKites;persist security info=False;user i" +
            "d=sa;workstation id=MAIN;packet size=4096";
         // 
         // dataSet11
         // 
         this.dataSet11.DataSetName = "DataSet1";
         this.dataSet11.Locale = new System.Globalization.CultureInfo("en-US");
         this.dataSet11.Namespace = "http://www.tempuri.org/DataSet1.xsd";
         // 
         // dataGrid1
         // 
         this.dataGrid1.CaptionVisible = false;
         this.dataGrid1.DataMember = "pProduct_Fetch";
         this.dataGrid1.DataSource = this.dataSet11;
         this.dataGrid1.Dock = System.Windows.Forms.DockStyle.Fill;
         this.dataGrid1.HeaderForeColor = System.Drawing.SystemColors.ControlText;
         this.dataGrid1.Name = "dataGrid1";
         this.dataGrid1.Size = new System.Drawing.Size(496, 365);
         this.dataGrid1.TabIndex = 0;
         // 
         // Form1
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(496, 365);
         this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                      this.dataGrid1});
         this.Name = "Form1";
         this.Text = "Simple Client Example";
         ((System.ComponentModel.ISupportInitialize)(this.dataSet11)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.dataGrid1)).EndInit();
         this.ResumeLayout(false);

      }
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new Form1());
		}
	}
}
