"""
Tests for the system status endpoint.
"""

from unittest.mock import patch, MagicMock
from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)

def test_system_status_unconfigured():
    """Test system status when Supabase is NOT configured."""
    with patch("app.api.v1.endpoints.system.is_supabase_configured", return_value=False):
        response = client.get("/api/v1/system/status")
        assert response.status_code == 200
        data = response.json()
        assert data["api_status"] == "healthy"
        assert data["database"]["status"] == "not_configured"
        assert "credentials are missing" in data["database"]["message"]


def test_system_status_connected():
    """Test system status when Supabase IS configured and connection succeeds."""
    mock_client = MagicMock()
    # Mock chain: mock_client.table().select().limit().execute()
    mock_response = MagicMock()
    mock_response.count = 42
    
    mock_limit = MagicMock()
    mock_limit.execute.return_value = mock_response
    
    mock_select = MagicMock()
    mock_select.limit.return_value = mock_limit
    
    mock_table = MagicMock()
    mock_table.select.return_value = mock_select
    
    mock_client.table.return_value = mock_table

    with patch("app.api.v1.endpoints.system.is_supabase_configured", return_value=True), \
         patch("app.api.v1.endpoints.system.get_supabase_client", return_value=mock_client):
        
        response = client.get("/api/v1/system/status")
        assert response.status_code == 200
        data = response.json()
        assert data["api_status"] == "healthy"
        assert data["database"]["status"] == "connected"
        assert data["database"]["stats"]["total_risk_cells"] == 42
        assert data["database"]["stats"]["total_sensors"] == 42


def test_system_status_error():
    """Test system status when Supabase IS configured but query fails."""
    with patch("app.api.v1.endpoints.system.is_supabase_configured", return_value=True), \
         patch("app.api.v1.endpoints.system.get_supabase_client", side_effect=Exception("DB Error")):
        
        response = client.get("/api/v1/system/status")
        assert response.status_code == 200
        data = response.json()
        assert data["api_status"] == "healthy"
        assert data["database"]["status"] == "error"
        assert data["database"]["stats"] is None
