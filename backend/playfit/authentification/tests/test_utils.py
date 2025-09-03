from django.test import TestCase
from authentification.utils import generate_username_with_number, generate_uid_from_id, get_id_from_uid, get_user_birthdate
from authentification.models import CustomUser
from unittest.mock import patch, Mock

class GenerateUsernameTestCase(TestCase):
    def setUp(self):
        self.user = CustomUser.objects.create_user(
            email="test@test.com",
            username="testuser_12345",
            password="test12345",
            date_of_birth="1990-01-01",
            height=180,
            weight=80,
        )

    def test_generate_unique_username(self):
        new_username = generate_username_with_number("testuser")

        self.assertNotEqual(new_username, "testuser_12345")
        self.assertTrue(new_username.startswith("testuser_"))

class UidTestCase(TestCase):
    def test_generate_uid_from_id(self):
        uid = generate_uid_from_id(1)
        self.assertEqual(uid, "AQAAAA")

    def test_get_id_from_uid(self):
        id = get_id_from_uid("AQAAAA")
        self.assertEqual(id, 1)

def _mock_response(status_code=200, json_data=None):
    m = Mock()
    m.status_code = status_code
    m.json = Mock(return_value=json_data or {})
    return m

class GetUserBirthdateTestCase(TestCase):
    def setUp(self):
        self.google_url = "https://people.googleapis.com/v1/people/me?personFields=birthdays"

    @patch('authentification.utils.requests.get')
    def test_returns_birthdate(self, mock_get):
        mock_get.return_value = _mock_response(
            200,
            {
                "birthdays": [
                    {"date": {"year": 1990, "month": 1, "day": 5}}
                ]
            },
        )
        token = "token123"
        result = get_user_birthdate(token)
        self.assertEqual(result, "1990-01-05")
        mock_get.assert_called_once_with(
            self.google_url,
            headers={"Authorization": f"Bearer {token}"},
        )

    @patch("authentification.utils.requests.get")
    def test_uses_first_valid_entry_with_year(self, mock_get):
        # First one missing year -> should skip; second one valid
        mock_get.return_value = _mock_response(
            200,
            {
                "birthdays": [
                    {"date": {"month": 12, "day": 31}},  # no year
                    {"date": {"year": 2001, "month": 9, "day": 8}},
                ]
            },
        )
        self.assertEqual(get_user_birthdate("t"), "2001-09-08")

    @patch("authentification.utils.requests.get")
    def test_returns_none_when_no_birthdays_key(self, mock_get):
        mock_get.return_value = _mock_response(200, {})
        self.assertIsNone(get_user_birthdate("t"))

    @patch("authentification.utils.requests.get")
    def test_returns_none_when_birthdays_empty_or_incomplete(self, mock_get):
        # Empty list
        mock_get.return_value = _mock_response(200, {"birthdays": []})
        self.assertIsNone(get_user_birthdate("t"))

        # Present but missing fields (e.g., missing day)
        mock_get.return_value = _mock_response(
            200, {"birthdays": [{"date": {"year": 1990, "month": 1}}]}
        )
        self.assertIsNone(get_user_birthdate("t"))

    @patch("authentification.utils.requests.get")
    def test_returns_none_on_non_200_status(self, mock_get):
        mock_get.return_value = _mock_response(401, {})
        self.assertIsNone(get_user_birthdate("t"))
