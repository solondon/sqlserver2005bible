using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Data.SqlClient;

namespace StoredProcedure
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class frmMain : System.Windows.Forms.Form
	{
      private System.Data.SqlClient.SqlConnection OBXKitesConnect;
      private System.Data.SqlClient.SqlCommand pProductFetch;
      private System.Data.DataSet SPOut;
      private System.Windows.Forms.Button btnQuit;
      private System.Windows.Forms.Button btnRun;
      private System.Windows.Forms.DataGrid SPDisplay;
      private System.Windows.Forms.TextBox txtProdCode;
      private System.Windows.Forms.Label label1;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public frmMain()
		{
			//
			// Required for Windows Form Designer support
			//
			InitializeComponent();

			//
			// TODO: Add any constructor code after InitializeComponent call
			//
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
         this.OBXKitesConnect = new System.Data.SqlClient.SqlConnection();
         this.pProductFetch = new System.Data.SqlClient.SqlCommand();
         this.SPOut = new System.Data.DataSet();
         this.btnQuit = new System.Windows.Forms.Button();
         this.btnRun = new System.Windows.Forms.Button();
         this.SPDisplay = new System.Windows.Forms.DataGrid();
         this.txtProdCode = new System.Windows.Forms.TextBox();
         this.label1 = new System.Windows.Forms.Label();
         ((System.ComponentModel.ISupportInitialize)(this.SPOut)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.SPDisplay)).BeginInit();
         this.SuspendLayout();
         // 
         // OBXKitesConnect
         // 
         this.OBXKitesConnect.ConnectionString = "data source=WINSERVER;initial catalog=OBXKites;integrated security=SSPI;persist s" +
            "ecurity info=True;workstation id=MAIN;packet size=4096";
         // 
         // pProductFetch
         // 
         this.pProductFetch.CommandText = "dbo.[pProduct_Fetch]";
         this.pProductFetch.CommandType = System.Data.CommandType.StoredProcedure;
         this.pProductFetch.Connection = this.OBXKitesConnect;
         this.pProductFetch.Parameters.Add(new System.Data.SqlClient.SqlParameter("@RETURN_VALUE", System.Data.SqlDbType.Int, 4, System.Data.ParameterDirection.ReturnValue, false, ((System.Byte)(10)), ((System.Byte)(0)), "", System.Data.DataRowVersion.Current, null));
         this.pProductFetch.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductCode", System.Data.SqlDbType.VarChar, 15));
         this.pProductFetch.Parameters.Add(new System.Data.SqlClient.SqlParameter("@ProductCategory", System.Data.SqlDbType.VarChar, 15));
         // 
         // SPOut
         // 
         this.SPOut.DataSetName = "NewDataSet";
         this.SPOut.Locale = new System.Globalization.CultureInfo("en-US");
         // 
         // btnQuit
         // 
         this.btnQuit.Location = new System.Drawing.Point(440, 8);
         this.btnQuit.Name = "btnQuit";
         this.btnQuit.TabIndex = 1;
         this.btnQuit.Text = "Quit";
         this.btnQuit.Click += new System.EventHandler(this.btnQuit_Click);
         // 
         // btnRun
         // 
         this.btnRun.Location = new System.Drawing.Point(440, 40);
         this.btnRun.Name = "btnRun";
         this.btnRun.TabIndex = 2;
         this.btnRun.Text = "Run";
         this.btnRun.Click += new System.EventHandler(this.btnRun_Click);
         // 
         // SPDisplay
         // 
         this.SPDisplay.DataMember = "";
         this.SPDisplay.DataSource = this.SPOut;
         this.SPDisplay.HeaderForeColor = System.Drawing.SystemColors.ControlText;
         this.SPDisplay.Location = new System.Drawing.Point(8, 8);
         this.SPDisplay.Name = "SPDisplay";
         this.SPDisplay.Size = new System.Drawing.Size(376, 256);
         this.SPDisplay.TabIndex = 3;
         // 
         // txtProdCode
         // 
         this.txtProdCode.Location = new System.Drawing.Point(392, 112);
         this.txtProdCode.Name = "txtProdCode";
         this.txtProdCode.Size = new System.Drawing.Size(120, 20);
         this.txtProdCode.TabIndex = 4;
         this.txtProdCode.Text = "";
         // 
         // label1
         // 
         this.label1.Location = new System.Drawing.Point(392, 80);
         this.label1.Name = "label1";
         this.label1.Size = new System.Drawing.Size(120, 32);
         this.label1.TabIndex = 5;
         this.label1.Text = "Add a product code (if desired):";
         // 
         // frmMain
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(522, 273);
         this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                      this.label1,
                                                                      this.txtProdCode,
                                                                      this.SPDisplay,
                                                                      this.btnRun,
                                                                      this.btnQuit});
         this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
         this.Name = "frmMain";
         this.Text = "Stored Procedure Example";
         ((System.ComponentModel.ISupportInitialize)(this.SPOut)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.SPDisplay)).EndInit();
         this.ResumeLayout(false);

      }
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new frmMain());
		}

      private void btnQuit_Click(object sender, System.EventArgs e)
      {
         // Exit the application.
         Close();
      }

      private void btnRun_Click(object sender, System.EventArgs e)
      {
         SqlDataReader  Output;  // The results of the query.
         DataColumn     Column;  // A single data column.
         DataRow        Row;     // A single data row.
         DataTable      Table;   // The addition to the DataSet.

         // Verify the DataSet doesn't already have the table built.
         if (SPOut.Tables["pProductFetch Output"] != null)
         {
            SPOut.Reset();
            pProductFetch.Parameters["@ProductCode"].Value = "";
            SPDisplay.Refresh();
         }

         // See if we have any input for the stored procedure.
         if (txtProdCode.Text.Length != 0)
            pProductFetch.Parameters["@ProductCode"].Value =
               txtProdCode.Text;

         // Open a connection to the database and execute the
         // stored procedure.
         OBXKitesConnect.Open();
         Output = pProductFetch.ExecuteReader();

         // Create a DataTable to store the information.
         Table = new DataTable("pProductFetch Output");

         // Create the columns found within the DataReader.
         for (int Counter = 0; Counter < Output.FieldCount; Counter++)
         {
            Column = new DataColumn(Output.GetName(Counter), 
                                    Output.GetFieldType(Counter));
            Table.Columns.Add(Column);
         }

         // Read the data one row at a time.
         while (Output.Read())
         {

            // Create a new row in the DataTable.
            Row = Table.NewRow();

            // Read the data from the DataReader into the DataTable.
            for (int Counter = 0; Counter < Output.FieldCount; Counter++)

               // Fill the row with data
               Row[Counter] = Output.GetValue(Counter);

            // Add the data to the table.
            Table.Rows.Add(Row);
         }

         // Add the table to the DataSet and then display it in the
         // DataGrid.
         SPOut.Tables.Add(Table);
         SPDisplay.DataMember = "pProductFetch Output";
         SPDisplay.CaptionText = "pProductFetch Output";
         SPDisplay.Refresh();

         // Close the connection now that we have the data.
         Output.Close();
         pProductFetch.Connection.Close();
         OBXKitesConnect.Close();
      }
	}
}
