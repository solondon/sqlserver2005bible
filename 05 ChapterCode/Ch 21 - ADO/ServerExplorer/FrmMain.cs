using System;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;
using System.Diagnostics;

namespace ServerExplorer
{
	/// <summary>
	/// Summary description for Form1.
	/// </summary>
	public class MainForm : System.Windows.Forms.Form
	{
      private System.Windows.Forms.Button btnQuit;
      private System.Windows.Forms.Button btnCreateEvent;
      private System.Diagnostics.EventLog ApplicationEvents;
      private System.Timers.Timer DataTimer;
      private System.Data.DataColumn BytesValue;
      private System.Windows.Forms.Button btnStopCounter;
      private System.Data.DataTable CounterDataTable;
      public System.Data.DataSet CounterData;
      private System.Diagnostics.PerformanceCounter UserProcessorTime;
      private System.Windows.Forms.DataGridTableStyle CounterDataStyle;
      private System.Windows.Forms.DataGridTextBoxColumn dataGridTextBoxColumn1;
      private System.Windows.Forms.DataGrid CounterDataView;
      private System.Windows.Forms.Label label1;
      private System.Windows.Forms.TextBox txtTimerInterval;
		/// <summary>
		/// Required designer variable.
		/// </summary>
		private System.ComponentModel.Container components = null;

		public MainForm()
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
         this.btnQuit = new System.Windows.Forms.Button();
         this.btnCreateEvent = new System.Windows.Forms.Button();
         this.ApplicationEvents = new System.Diagnostics.EventLog();
         this.CounterData = new System.Data.DataSet();
         this.CounterDataTable = new System.Data.DataTable();
         this.BytesValue = new System.Data.DataColumn();
         this.DataTimer = new System.Timers.Timer();
         this.btnStopCounter = new System.Windows.Forms.Button();
         this.UserProcessorTime = new System.Diagnostics.PerformanceCounter();
         this.CounterDataView = new System.Windows.Forms.DataGrid();
         this.CounterDataStyle = new System.Windows.Forms.DataGridTableStyle();
         this.dataGridTextBoxColumn1 = new System.Windows.Forms.DataGridTextBoxColumn();
         this.label1 = new System.Windows.Forms.Label();
         this.txtTimerInterval = new System.Windows.Forms.TextBox();
         ((System.ComponentModel.ISupportInitialize)(this.ApplicationEvents)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.CounterData)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.CounterDataTable)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.DataTimer)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.UserProcessorTime)).BeginInit();
         ((System.ComponentModel.ISupportInitialize)(this.CounterDataView)).BeginInit();
         this.SuspendLayout();
         // 
         // btnQuit
         // 
         this.btnQuit.Location = new System.Drawing.Point(240, 8);
         this.btnQuit.Name = "btnQuit";
         this.btnQuit.TabIndex = 0;
         this.btnQuit.Text = "Quit";
         this.btnQuit.Click += new System.EventHandler(this.btnQuit_Click);
         // 
         // btnCreateEvent
         // 
         this.btnCreateEvent.Location = new System.Drawing.Point(240, 40);
         this.btnCreateEvent.Name = "btnCreateEvent";
         this.btnCreateEvent.Size = new System.Drawing.Size(75, 40);
         this.btnCreateEvent.TabIndex = 1;
         this.btnCreateEvent.Text = "Create Event";
         this.btnCreateEvent.Click += new System.EventHandler(this.btnCreateEvent_Click);
         // 
         // ApplicationEvents
         // 
         this.ApplicationEvents.EnableRaisingEvents = true;
         this.ApplicationEvents.Log = "Application";
         this.ApplicationEvents.MachineName = "MAIN";
         this.ApplicationEvents.Source = "Server Explorer Demonstration";
         this.ApplicationEvents.SynchronizingObject = this;
         this.ApplicationEvents.EntryWritten += new System.Diagnostics.EntryWrittenEventHandler(this.ApplicationEvents_EntryWritten);
         // 
         // CounterData
         // 
         this.CounterData.DataSetName = "CounterDataSet";
         this.CounterData.Locale = new System.Globalization.CultureInfo("en-US");
         this.CounterData.Namespace = "CounterData";
         this.CounterData.Prefix = "CDS";
         this.CounterData.Tables.AddRange(new System.Data.DataTable[] {
                                                                         this.CounterDataTable});
         // 
         // CounterDataTable
         // 
         this.CounterDataTable.Columns.AddRange(new System.Data.DataColumn[] {
                                                                                this.BytesValue});
         this.CounterDataTable.TableName = "UserProcessorTime";
         // 
         // BytesValue
         // 
         this.BytesValue.AllowDBNull = false;
         this.BytesValue.ColumnName = "Total Percent User Time";
         this.BytesValue.DataType = typeof(System.Double);
         this.BytesValue.DefaultValue = 0;
         // 
         // DataTimer
         // 
         this.DataTimer.Enabled = true;
         this.DataTimer.Interval = 500;
         this.DataTimer.SynchronizingObject = this;
         this.DataTimer.Elapsed += new System.Timers.ElapsedEventHandler(this.DataTimer_Elapsed);
         // 
         // btnStopCounter
         // 
         this.btnStopCounter.Location = new System.Drawing.Point(240, 88);
         this.btnStopCounter.Name = "btnStopCounter";
         this.btnStopCounter.Size = new System.Drawing.Size(75, 40);
         this.btnStopCounter.TabIndex = 3;
         this.btnStopCounter.Text = "Stop Counter";
         this.btnStopCounter.Click += new System.EventHandler(this.btnStopCounter_Click);
         // 
         // UserProcessorTime
         // 
         this.UserProcessorTime.CategoryName = "Processor";
         this.UserProcessorTime.CounterName = "% User Time";
         this.UserProcessorTime.InstanceName = "_Total";
         this.UserProcessorTime.MachineName = "MAIN";
         // 
         // CounterDataView
         // 
         this.CounterDataView.DataMember = "UserProcessorTime";
         this.CounterDataView.DataSource = this.CounterData;
         this.CounterDataView.Dock = System.Windows.Forms.DockStyle.Left;
         this.CounterDataView.HeaderForeColor = System.Drawing.SystemColors.ControlText;
         this.CounterDataView.Name = "CounterDataView";
         this.CounterDataView.Size = new System.Drawing.Size(224, 406);
         this.CounterDataView.TabIndex = 5;
         this.CounterDataView.TableStyles.AddRange(new System.Windows.Forms.DataGridTableStyle[] {
                                                                                                    this.CounterDataStyle});
         // 
         // CounterDataStyle
         // 
         this.CounterDataStyle.DataGrid = this.CounterDataView;
         this.CounterDataStyle.GridColumnStyles.AddRange(new System.Windows.Forms.DataGridColumnStyle[] {
                                                                                                           this.dataGridTextBoxColumn1});
         this.CounterDataStyle.HeaderForeColor = System.Drawing.SystemColors.ControlText;
         this.CounterDataStyle.MappingName = "UserProcessorTime";
         // 
         // dataGridTextBoxColumn1
         // 
         this.dataGridTextBoxColumn1.Format = "";
         this.dataGridTextBoxColumn1.FormatInfo = null;
         this.dataGridTextBoxColumn1.HeaderText = "Total Percent User Time";
         this.dataGridTextBoxColumn1.MappingName = "Total Percent User Time";
         this.dataGridTextBoxColumn1.Width = 150;
         // 
         // label1
         // 
         this.label1.Location = new System.Drawing.Point(232, 144);
         this.label1.Name = "label1";
         this.label1.TabIndex = 6;
         this.label1.Text = "Timer Interval:";
         // 
         // txtTimerInterval
         // 
         this.txtTimerInterval.Location = new System.Drawing.Point(232, 168);
         this.txtTimerInterval.Name = "txtTimerInterval";
         this.txtTimerInterval.TabIndex = 7;
         this.txtTimerInterval.Text = "500";
         this.txtTimerInterval.TextChanged += new System.EventHandler(this.txtTimerInterval_TextChanged);
         // 
         // MainForm
         // 
         this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
         this.ClientSize = new System.Drawing.Size(338, 406);
         this.Controls.AddRange(new System.Windows.Forms.Control[] {
                                                                      this.txtTimerInterval,
                                                                      this.label1,
                                                                      this.CounterDataView,
                                                                      this.btnStopCounter,
                                                                      this.btnCreateEvent,
                                                                      this.btnQuit});
         this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
         this.Name = "MainForm";
         this.Text = "Server Explorer Demonstration";
         ((System.ComponentModel.ISupportInitialize)(this.ApplicationEvents)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.CounterData)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.CounterDataTable)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.DataTimer)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.UserProcessorTime)).EndInit();
         ((System.ComponentModel.ISupportInitialize)(this.CounterDataView)).EndInit();
         this.ResumeLayout(false);

      }
		#endregion

		/// <summary>
		/// The main entry point for the application.
		/// </summary>
		[STAThread]
		static void Main() 
		{
			Application.Run(new MainForm());
		}

      private void btnQuit_Click(object sender, System.EventArgs e)
      {
         // Exit the application.
         Close();
      }

      private void btnCreateEvent_Click(object sender, System.EventArgs e)
      {
         // Create an event entry.
         ApplicationEvents.WriteEntry("This is a test message",
                                      EventLogEntryType.Information,
                                      1001,
                                      1);
      }

      private void ApplicationEvents_EntryWritten(object sender, 
         System.Diagnostics.EntryWrittenEventArgs e)
      {
         // Respond to the entry written event.
         MessageBox.Show("The Application Generated an Event!" +
                         "\r\nType:\t\t" + e.Entry.EntryType.ToString() +
                         "\r\nCategory:\t" + e.Entry.Category.ToString() +
                         "\r\nEvent ID:\t\t" + e.Entry.EventID.ToString() +
                         "\r\nSource:\t\t" + e.Entry.Source.ToString() +
                         "\r\nMessage:\t\t" + e.Entry.Message.ToString() +
                         "\r\nTime Created:\t" + e.Entry.TimeGenerated.ToString(),
                         "Application Event",
                         MessageBoxButtons.OK,
                         MessageBoxIcon.Information);
      }

      private void DataTimer_Elapsed(object sender, System.Timers.ElapsedEventArgs e)
      {
         DataTable   CounterTable;
         DataRow     NewRow;

         // Create the data table object.
         CounterTable = CounterData.Tables["UserProcessorTime"];

         // Create a new row for the data table.
         NewRow = CounterTable.NewRow();

         // Obtain the current performance counter value.
         NewRow["Total Percent User Time"] = 
            UserProcessorTime.NextValue();

         // Store the value in the data table.
         CounterTable.Rows.Add(NewRow);

         // Verify the size of the data table and remove
         // a record if necessary.
         if (CounterTable.Rows.Count >= CounterDataView.VisibleRowCount)
            CounterTable.Rows.RemoveAt(0);
      }

      private void btnStopCounter_Click(object sender, System.EventArgs e)
      {
         // Start and stop the timer as needed.  Change the
         // caption to show the current timer state.
         if (btnStopCounter.Text == "Stop Counter")
         {
            DataTimer.Stop();
            btnStopCounter.Text = "Start Counter";
         }
         else
         {
            DataTimer.Start();
            btnStopCounter.Text = "Stop Counter";
         }
      }

      private void txtTimerInterval_TextChanged(object sender, System.EventArgs e)
      {
         try
         {
            // Verify the timer change value has a number in it.
            if (Int64.Parse(txtTimerInterval.Text) == 0)
               // If not, reset the value.
               txtTimerInterval.Text = DataTimer.Interval.ToString();
            else
               // If so, use the new value.
               DataTimer.Interval = Int64.Parse(txtTimerInterval.Text);
         }
         catch
         {
            // Catch invalid values.
            MessageBox.Show("Type Only Numeric Values!",
               "Input Error",
               MessageBoxButtons.OK,
               MessageBoxIcon.Error);
            txtTimerInterval.Text = DataTimer.Interval.ToString();
         }
      }
	}
}
