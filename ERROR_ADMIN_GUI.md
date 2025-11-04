# BijbelQuiz Error Reporting Admin GUI

A Python-based graphical user interface for administrators to view and manage reported errors from the BijbelQuiz app.

## Features

- View all reported errors from the Supabase database
- Filter errors by type, user ID, or question ID
- View detailed information for each error
- Refresh data to get the latest reports
- Sortable columns for easy data analysis

## Requirements

- Python 3.7+
- Supabase project with error reporting table
- Service role key for admin access

## Installation

1. Install the required Python packages:
   ```bash
   pip install -r error_admin_requirements.txt
   ```

2. Set up your Supabase credentials in a `.env` file:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
   ```

3. Run the admin GUI:
   ```bash
   python error_admin_gui.py
   ```

## Configuration

### Environment Variables

Create a `.env` file in the main project directory with the following variables:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_SERVICE_ROLE_KEY`: Your Supabase service role key (for admin access)

### Supabase Setup

Make sure your Supabase project has the `error_reports` table created with the proper schema. The table should match the structure used by the error reporting service in the app.

The required RLS policies should allow the service role to read all error reports:
```sql
-- Policy to allow service role to access all records
CREATE POLICY "Allow service role access to error reports" ON error_reports
    FOR ALL USING (auth.role() = 'service_role');
```

## Usage

1. Ensure your environment variables are set up correctly
2. Run the Python script: `python error_admin_gui.py`
3. The application will connect to Supabase and load all error reports
4. Use the filter controls to narrow down the results:
   - Error Type: Filter by specific error types
   - User ID: Filter by specific user
   - Question ID: Filter by specific question
5. Click on any error in the list to view detailed information
6. Use the "Refresh" button to reload data
7. Use the "Clear Filters" button to reset all filters

## Security

This admin interface should only be used by authorized personnel:
- Uses the service role key for admin-level access to Supabase
- Should only be run in secure environments
- Do not share the service role key or environment file

## Troubleshooting

- If you get connection errors, verify your Supabase URL and service role key
- If the app loads but shows no errors, verify that the `error_reports` table exists and has data
- Make sure your Supabase RLS policies allow service role access to the error reports table